
const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const readline = require("node:readline/promises");
const { stdin, stdout } = require("node:process");

const PROJECT_ID = "todo-14f2e";
const ADMIN_UID = "4pOg3QcX0rXkXurM04GFWJ4JxjD3";

initializeApp({
  credential: applicationDefault(),
  projectId: PROJECT_ID,
});

async function main() {
  const auth = getAuth();

  // Verify the target account before changing its permissions.
  const user = await auth.getUser(ADMIN_UID);

  console.log("\nTarget Firebase account:");
  console.log("UID:", user.uid);
  console.log("Email:", user.email || "No email");
  console.log("Existing admin claim:", user.customClaims?.admin === true);

  if (user.customClaims?.admin === true) {
    console.log("\nThis account is already an admin.");
    return;
  }

  const rl = readline.createInterface({ input: stdin, output: stdout });

  const answer = await rl.question(
    "\nType GRANT ADMIN to grant admin privileges: "
  );

  rl.close();

  if (answer !== "GRANT ADMIN") {
    console.log("Operation cancelled. No changes made.");
    return;
  }

  await auth.setCustomUserClaims(ADMIN_UID, {
    ...(user.customClaims || {}),
    admin: true,
  });

  console.log("\nSUCCESS: Admin claim granted.");
  console.log("The user must sign in again or refresh their ID token.");
}

main().catch((error) => {
  console.error("\nBootstrap failed:");
  console.error("Error code:", error.code);
  console.error("Error message:", error.message);
  console.error("Error details:", error.errorInfo);
  console.error("Full error:", error);
  process.exitCode = 1;
});
