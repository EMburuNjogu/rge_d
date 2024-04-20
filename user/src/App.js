import { useState } from 'react';
import { ConnectWallet, useConnectedWallet } from "@thirdweb-dev/react";
import { useContract } from "@thirdweb-dev/react";
import { UserManagement } from "@thirdweb-dev/sdk"; // Assuming your contract is named UserManagement

const contractAddress = '0x251964C9abEcF2E55e9294ec4891A1286a4B9d9c'; // Replace with your contract address

export default function Home() {
  const [phoneNumber, setPhoneNumber] = useState('');
  const [verificationResult, setVerificationResult] = useState('');
  const connectedWallet = useConnectedWallet();

  // Use useContract hook to get the contract instance
  const contract = useContract(contractAddress, UserManagement); // Assuming your contract is named UserManagement

  const handleRegisterUser = async () => {
    // Check if wallet is connected
    if (!connectedWallet) {
      console.error('Wallet not connected');
      return;
    }

    // Call smart contract function to register user with phoneNumber
    try {
      const tx = await contract.registerUser(ethers.utils.keccak256(phoneNumber));
      await tx.wait();
      console.log('User registered successfully!');
    } catch (error) {
      console.error('Registration failed:', error.message);
    }
  };

  const handleVerifyWalletOwner = async () => {
    // Check if wallet is connected
    if (!connectedWallet) {
      console.error('Wallet not connected');
      return;
    }

    // Sign a message using the connected wallet
    const message = "Verify ownership";
    const signature = await connectedWallet.signMessage(message);

    try {
      const tx = await contract.loginUser(signature);
      await tx.wait();
      console.log('Verification successful!');
      setVerificationResult('Verification successful');
    } catch (error) {
      console.error('Verification failed:', error.message);
      setVerificationResult('Verification failed');
    }
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
