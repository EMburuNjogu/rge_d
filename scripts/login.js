import { config } from 'dotenv';
import { createThirdwebClient, getContract, prepareContractCall, sendTransaction, resolveMethod } from "thirdweb";

// Load environment variables from .env.local file
config();

// Create the client with your clientId
const client = createThirdwebClient({ clientId: process.env.YOUR_CLIENT_ID });

// Connect to your contract
const contract = getContract({ client, chain: undefined, address: "0x251964C9abEcF2E55e9294ec4891A1286a4B9d9c" });

async function loginUser(signature) {
  try {
    const transaction = await prepareContractCall({ contract, method: resolveMethod("loginUser"), params: [signature] });
    const { transactionHash } = await sendTransaction({ transaction });
    console.log('User logged in successfully. Transaction Hash:', transactionHash);
  } catch (error) {
    console.error('Error logging in user:', error);
  }
}

// Example usage: login a user with a signature
const exampleSignature = "0x123456789abcdef"; // Replace with a valid signature
loginUser(exampleSignature);
