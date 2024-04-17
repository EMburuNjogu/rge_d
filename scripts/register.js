//rge_d/scripts/register.js

import { config } from 'dotenv';
import { createThirdwebClient, getContract, prepareContractCall, sendTransaction, resolveMethod } from "thirdweb";

// Load environment variables from .env.local file
config();

// Create the client with your clientId
const client = createThirdwebClient({ clientId: process.env.YOUR_CLIENT_ID });

// Connect to your contract
const contract = getContract({ client, chain: undefined, address: "0x251964C9abEcF2E55e9294ec4891A1286a4B9d9c" });

async function registerUser(phoneNumber) {
  try {
    const transaction = await prepareContractCall({ contract, method: resolveMethod("registerUser"), params: [phoneNumber] });
    const { transactionHash } = await sendTransaction({ transaction });
    console.log('User registered successfully. Transaction Hash:', transactionHash);
  } catch (error) {
    console.error('Error registering user:', error);
  }
}

// Example usage: register a user with phone number '123456789'
registerUser('123456789');
