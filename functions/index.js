
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

const {
  onCall,
  HttpsError,
} = require("firebase-functions/v2/https");

const { setGlobalOptions } = require("firebase-functions");

initializeApp();

setGlobalOptions({
  maxInstances: 10,
});

// The only account allowed to bootstrap admin privileges.
const INITIAL_ADMIN_UID = "4pOg3QcX0rXkXurM04GFWJ4JxjD3";

exports.bootstrapAdmin = onCall(
  { maxInstances: 1 },
  async (request) => {
    // Require an authenticated user.
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must sign in first."
      );
    }

    // Only the predefined account can receive admin privileges.
    if (request.auth.uid !== INITIAL_ADMIN_UID) {
      throw new HttpsError(
        "permission-denied",
        "You are not allowed to perform this operation."
      );
    }

    try {
      const auth = getAuth();

      const user = await auth.getUser(INITIAL_ADMIN_UID);

      const existingClaims = user.customClaims || {};

      await auth.setCustomUserClaims(INITIAL_ADMIN_UID, {
        ...existingClaims,
        admin: true,
      });

      return {
        success: true,
        message: "Admin privileges granted successfully.",
      };
    } catch (error) {
      console.error("Bootstrap Admin Error:", error);

      throw new HttpsError(
        "internal",
        "Failed to grant admin privileges."
      );
    }
  }
);
