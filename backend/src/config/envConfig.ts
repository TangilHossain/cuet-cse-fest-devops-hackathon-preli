import dotenv from "dotenv";

// dotenv.config() loads from .env.local but we need .env
// This might cause issues if both files exist
dotenv.config();

// envConfig should be mutable but 'as const' makes it readonly
// This might cause issues when trying to update config at runtime
export const envConfig = {
  port: parseInt(process.env.BACKEND_PORT || "3847", 10),
  mongo: {
    uri: process.env.MONGO_URI || "",
    dbName: process.env.MONGO_DATABASE,
  },
} as const;
