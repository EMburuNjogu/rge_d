// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Quarsar.sol"; // Import your Quasar oracle interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // Import OpenZeppelin ERC20 interface
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DexSwap {
    using SafeMath for uint256;

    Quasar internal quasarOracle; // Quasar oracle interface
    uint256 public fedPriceUSD; // Current FED price in USD (wei)
    address public owner; // Contract owner address
    IERC20 public usdtToken; // OpenZeppelin ERC20 interface for USDT
    IERC20 public fedToken; // OpenZeppelin ERC20 interface for FED

    event Swap(address fromToken, address toToken, uint256 amountIn, uint256 amountOut);
    event FedPriceUpdated(uint256 newPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can update the FED price");
        _;
    }

    constructor(
        address _quasarOracleAddress,
        address _usdtTokenAddress,
        address _fedTokenAddress
    ) {
        quasarOracle = Quasar(_quasarOracleAddress); // Initialize Quasar oracle interface
        fedPriceUSD = 750000000; // Assuming 1 FED = 0.0075 USDT
        owner = msg.sender;
        usdtToken = IERC20(_usdtTokenAddress); // Initialize the OpenZeppelin ERC20 interface for USDT
        fedToken = IERC20(_fedTokenAddress); // Initialize the OpenZeppelin ERC20 interface for FED
    }

    /**
     * @dev Updates the current FED price in USD (wei) based on the fixed conversion rate.
     * Only the contract owner can call this function.
     * @param newPrice The new FED price in USD (wei).
     */
    function updateFedPrice(uint256 newPrice) external onlyOwner {
        fedPriceUSD = newPrice;
        emit FedPriceUpdated(newPrice);
    }

    /**
     * @dev Swaps USDT tokens for FED tokens with proper decimal handling.
     * @param usdtAmount The amount of USDT tokens to swap.
     * @return The amount of FED tokens received.
     */
    function usdtToFedSwap(uint256 usdtAmount) public returns (uint256) {
        // Calculate the amount of FED tokens to be received using SafeMath to prevent overflow
        uint256 fedAmount = usdtAmount.mul(fedPriceUSD).div(10**18);
        require(usdtToken.transferFrom(msg.sender, address(this), usdtAmount), "USDT transfer failed");
        require(fedToken.transfer(msg.sender, fedAmount), "FED transfer failed");
        emit Swap(address(usdtToken), address(fedToken), usdtAmount, fedAmount); // Emit swap event
        return fedAmount;
    }

    /**
     * @dev Swaps FED tokens for USDT tokens with proper decimal handling.
     * @param fedAmount The amount of FED tokens to swap.
     * @return The amount of USDT tokens received.
     */
    function fedToUsdtSwap(uint256 fedAmount) public returns (uint256) {
        // Calculate the amount of USDT tokens to be received using SafeMath to prevent overflow
        uint256 usdtAmount = fedAmount.mul(10**18).div(fedPriceUSD);
        require(fedToken.transferFrom(msg.sender, address(this), fedAmount), "FED transfer failed");
        require(usdtToken.transfer(msg.sender, usdtAmount), "USDT transfer failed");
        emit Swap(address(fedToken), address(usdtToken), fedAmount, usdtAmount); // Emit swap event
        return usdtAmount;
    }
}
