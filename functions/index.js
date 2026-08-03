const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const {setGlobalOptions} = require("firebase-functions/v2");
const {logger} = require("firebase-functions");

initializeApp();

// Match Firestore/Eventarc region for this project.
setGlobalOptions({region: "asia-south1"});

function routeForType(type) {
  switch (type) {
    case "order_assigned":
    case "order_out_for_delivery":
    case "order_rider_arrived":
    case "order_message":
    case "staff_message":
    case "payment_reminder":
    case "order_created":
    case "order_delivered":
    case "order_failed":
    case "order_cancelled":
      return "/";
    case "order_review":
      return "/orders";
    case "admin_message":
    default:
      return "/notifications";
  }
}

async function createNotification({
  userId,
  title,
  body,
  type,
  orderId,
  createdById,
  createdByRole,
  createdByName,
}) {
  if (!userId) return;
  await getFirestore().collection("notifications").add({
    userId,
    title,
    body,
    type,
    orderId: orderId || null,
    createdById: createdById || "system",
    createdByRole: createdByRole || "system",
    createdByName: createdByName || "Pakola Waters",
    read: false,
    createdAt: FieldValue.serverTimestamp(),
  });
}

async function listBranchSupervisors(branchId) {
  if (!branchId) return [];
  const snap = await getFirestore()
      .collection("users")
      .where("role", "==", "supervisor")
      .get();
  return snap.docs
      .map((doc) => ({id: doc.id, ...doc.data()}))
      .filter((user) => user.primaryBranchId === branchId);
}

/**
 * Sends an FCM push whenever an in-app notification document is created.
 * Tokens are stored on users/{userId}.fcmTokens.
 */
exports.onNotificationCreated = onDocumentCreated(
    "notifications/{notificationId}",
    async (event) => {
      const snapshot = event.data;
      if (!snapshot) return;

      const data = snapshot.data() || {};
      const userId = data.userId;
      if (!userId) {
        logger.warn("Notification missing userId", {id: snapshot.id});
        return;
      }

      const userRef = getFirestore().collection("users").doc(userId);
      const userSnap = await userRef.get();
      if (!userSnap.exists) {
        logger.warn("Notification user not found", {userId});
        return;
      }

      const tokens = (userSnap.data().fcmTokens || []).filter(
          (token) => typeof token === "string" && token.trim().length > 0,
      );
      if (tokens.length === 0) {
        logger.info("No FCM tokens for user", {userId});
        return;
      }

      const type = data.type || "general";
      const orderId = data.orderId || "";
      const title = data.title || "Pakola Waters";
      const body = data.body || "";

      const response = await getMessaging().sendEachForMulticast({
        tokens,
        notification: {title, body},
        data: {
          type: String(type),
          orderId: String(orderId),
          route: routeForType(type),
          notificationId: snapshot.id,
          title: String(title),
          body: String(body),
        },
        android: {
          priority: "high",
          notification: {
            channelId: "pakola_waters_default",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      });

      const invalidTokens = [];
      response.responses.forEach((result, index) => {
        if (result.success) return;
        const code = result.error && result.error.code;
        if (
          code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token"
        ) {
          invalidTokens.push(tokens[index]);
        } else {
          logger.error("FCM send failed", {
            userId,
            code,
            message: result.error && result.error.message,
          });
        }
      });

      if (invalidTokens.length > 0) {
        await userRef.update({
          fcmTokens: FieldValue.arrayRemove(...invalidTokens),
        });
      }

      logger.info("Push sent", {
        userId,
        successCount: response.successCount,
        failureCount: response.failureCount,
      });
    },
);

/**
 * Creates in-app notifications (and therefore pushes) for order lifecycle events.
 */
exports.onOrderWritten = onDocumentUpdated(
    "orders/{orderId}",
    async (event) => {
      const before = event.data.before.data() || {};
      const after = event.data.after.data() || {};
      const orderId = event.params.orderId;
      const beforeStatus = before.status;
      const afterStatus = after.status;
      if (!afterStatus || beforeStatus === afterStatus) return;

      const productName = after.productName || "Order";
      const customerName = after.customerName || "Customer";
      const qty = after.quantity || 1;
      const branchId = after.branchId;
      const supervisorId = after.supervisorId;
      const riderId = after.riderId;
      const customerId = after.customerId;

      if (afterStatus === "delivered" && beforeStatus !== "delivered") {
        const title = "Order delivered";
        const body =
            `${customerName} confirmed delivery of ${productName} x${qty}.`;
        if (supervisorId) {
          await createNotification({
            userId: supervisorId,
            title,
            body,
            type: "order_delivered",
            orderId,
            createdById: customerId || "system",
            createdByRole: "customer",
            createdByName: customerName,
          });
        }
        if (riderId) {
          await createNotification({
            userId: riderId,
            title,
            body:
                `${customerName} confirmed your delivery of ${productName} x${qty}.`,
            type: "order_delivered",
            orderId,
            createdById: customerId || "system",
            createdByRole: "customer",
            createdByName: customerName,
          });
        }
        return;
      }

      if (
        (afterStatus === "failed" || afterStatus === "cancelled") &&
        beforeStatus !== afterStatus
      ) {
        const isFailed = afterStatus === "failed";
        const isCancelled = afterStatus === "cancelled";
        const reasonText = after.failureReason || after.cancellationReason || "";
        const reason = reasonText ? ` Reason: ${reasonText}` : "";

        const cancelledByRole = after.cancelledByRole || "";
        const cancelledByName =
            after.cancelledByName || after.adminActionByName || "Admin";
        const cancelledById =
            after.cancelledById || after.adminActionById || "system";

        let title;
        let body;
        let actorRole = "admin";
        if (isFailed) {
          title = "Order failed";
          body =
              `${productName} x${qty} for ${customerName} was failed.${reason}`;
          actorRole = "admin";
        } else if (cancelledByRole === "customer") {
          title = "Order cancelled by customer";
          body =
              `${customerName} cancelled ${productName} x${qty}.${reason}`;
          actorRole = "customer";
        } else if (cancelledByRole === "admin") {
          title = "Order cancelled by admin";
          body =
              `Admin (${cancelledByName}) cancelled ${productName} x${qty} for ${customerName}.${reason}`;
          actorRole = "admin";
        } else {
          title = "Order cancelled";
          body =
              `${productName} x${qty} for ${customerName} was cancelled.${reason}`;
          actorRole = cancelledByRole || "admin";
        }

        const type = isFailed ? "order_failed" : "order_cancelled";

        // Always notify assigned rider + supervisor.
        // Notify customer only when admin/staff cancelled (not self-cancel).
        const recipients = new Set([supervisorId, riderId].filter(Boolean));
        if (isFailed || (isCancelled && cancelledByRole !== "customer")) {
          if (customerId) recipients.add(customerId);
        }

        for (const userId of recipients) {
          await createNotification({
            userId,
            title,
            body,
            type,
            orderId,
            createdById: cancelledById,
            createdByRole: actorRole,
            createdByName: cancelledByName,
          });
        }
        return;
      }
    },
);

exports.onOrderCreated = onDocumentCreated(
    "orders/{orderId}",
    async (event) => {
      const snapshot = event.data;
      if (!snapshot) return;
      const order = snapshot.data() || {};
      const orderId = snapshot.id;
      const branchId = order.branchId;
      const productName = order.productName || "Order";
      const customerName = order.customerName || "Customer";
      const qty = order.quantity || 1;
      const customerId = order.customerId || "system";

      const supervisors = await listBranchSupervisors(branchId);
      if (supervisors.length === 0) {
        logger.info("No supervisors for branch on new order", {branchId, orderId});
        return;
      }

      for (const supervisor of supervisors) {
        await createNotification({
          userId: supervisor.id,
          title: "New order requested",
          body: `${customerName} ordered ${productName} x${qty}.`,
          type: "order_created",
          orderId,
          createdById: customerId,
          createdByRole: "customer",
          createdByName: customerName,
        });
      }
    },
);
