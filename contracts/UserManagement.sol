// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @title UserManagement
 * @dev A smart contract to manage user registration and login in a decentralized application (DApp).
 */
contract UserManagement {
    // Mapping to store hashed user phone numbers
    mapping(address => string) public phoneNumbers;

    // Event to notify user registration
    event UserRegistered(address indexed user, string phoneNumber);

    // Event to notify user login
    event UserLoggedIn(address indexed user);

    // EIP-712 domain separator for signature verification
    bytes32 DOMAIN_SEPARATOR;

    /**
     * @dev Constructor to initialize the domain separator.
     */
    constructor() {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("UserManagement")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    /**
     * @dev Function to register a new user with a phone number and bind their wallet.
     * @param phoneNumber The user's phone number.
     */
    function registerUser(string calldata phoneNumber) public {
        bytes32 hashedPhone = keccak256(abi.encodePacked(phoneNumber)); // Hash the phone number
        require(bytes(phoneNumbers[msg.sender]).length == 0, "User already registered");

        phoneNumbers[msg.sender] = string(abi.encodePacked(hashedPhone)); // Store the hashed value
        emit UserRegistered(msg.sender, phoneNumber);
    }

    /**
     * @dev Function to login existing user using their wallet address and signed message.
     * @param signature The user's signed message.
     * @return A boolean indicating successful login.
     */
    function loginUser(bytes calldata signature) external returns (bool) {
        require(bytes(phoneNumbers[msg.sender]).length > 0, "User not registered");

        // Derive message hash using EIP-712 domain separator
        bytes32 messageHash = keccak256(abi.encodePacked(
            DOMAIN_SEPARATOR,
            keccak256(abi.encodePacked("Verify User:", msg.sender))
        ));

        // Verify the signature using recovered signer address
        require(verifySignature(messageHash, signature) == msg.sender, "Invalid signature");

        emit UserLoggedIn(msg.sender);
        return true;
    }

    /**
     * @dev Internal function to verify the signature using recovered signer address.
     * @param messageHash The hash of the message to be signed.
     * @param signature The user's signature.
     * @return The address of the recovered signer.
     */
    function verifySignature(bytes32 messageHash, bytes calldata signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        require(signature.length == 65, "Invalid signature length");

        bytes memory signatureBytes = new bytes(signature.length);
        assembly {
        calldatacopy(add(signatureBytes, 32), 0, signature.length)
        r := mload(add(signatureBytes, 32))
        s := mload(add(signatureBytes, 64))
        v := byte(0, mload(add(signatureBytes, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        return ecrecover(messageHash, v, r, s);
    }
}
