import { useState } from 'react';
import { ConnectWallet, useWallet, getContract, prepareContractCall, sendTransaction, resolveMethod } from "@thirdweb-dev/react";
import { createThirdwebClient } from "thirdweb";
import dotenv from 'dotenv';

dotenv.config();


const contractAddress = '0x251964C9abEcF2E55e9294ec4891A1286a4B9d9c'; // Replace with your contract address

export default function Home() {
  const [phoneNumber, setPhoneNumber] = useState('');
  const [verificationResult, setVerificationResult] = useState('');
  const { account } = useWallet();

  // Define 'client' using createThirdwebClient
  const client = createThirdwebClient({ clientId: process.env.YOUR_CLIENT_ID }); // Replace YOUR_CLIENT_ID with your actual client ID

  const handleRegisterUser = () => {
    // Call smart contract function to register user with phoneNumber
    console.log('Registering user with phone number:', phoneNumber);
  };

  const handleVerifyWalletOwner = async () => {
    // Check if wallet is connected
    if (!account) {
      console.error('Wallet not connected');
      return;
    }

    // Sign a message
    const message = 'Verify ownership';
    const messageHash = await createMessageHash(message);
    const signature = await signMessage(messageHash);

    // Call smart contract function to verify signature
    const contract = getContract({ client, chain: undefined, address: contractAddress });
    try {
      const result = await prepareContractCall({ contract, method: resolveMethod("verifySignature"), params: [messageHash, signature] });
      const { transactionHash } = await sendTransaction({ transaction: result });
      console.log('Verification successful. Transaction Hash:', transactionHash);
      setVerificationResult('Verification successful');
    } catch (error) {
      console.error('Verification failed:', error.message);
      setVerificationResult('Verification failed');
    }
  };

  const createMessageHash = async (message) => {
    // Logic to create message hash
    return message; // Replace with actual logic
  };

  const signMessage = async (messageHash) => {
    // Logic to sign message
    return '0x123456789abcdef'; // Replace with actual signature
  };

  return (
    <main className="main">
      <div className="container">
        <div className="header">
          <h1 className="title">
            Welcome to{" "}
            <span className="gradient-text-0">
              <a
                href="https://thirdweb.com/"
                target="_blank"
                rel="noopener noreferrer"
              >
                Fedhadex
              </a>
            </span>
          </h1>
        </div>

        <div className="connect">
          <ConnectWallet />
        </div>

        <div className="form">
          <input
            type="text"
            placeholder="Enter Phone Number"
            value={phoneNumber}
            onChange={(e) => setPhoneNumber(e.target.value)}
          />
          <button onClick={handleRegisterUser}>Register User</button>
        </div>

        <div className="verify">
          <button onClick={handleVerifyWalletOwner}>Verify Wallet Ownership</button>
          <p>{verificationResult}</p>
        </div>
      </div>
    </main>
  );
}
