// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@thirdweb-dev/contracts/base/ERC20Base.sol"; // Import ThirdWeb ERC20Base
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SwapDEX {
    using SafeMath for uint256;

    AggregatorV3Interface internal priceFeed; // Chainlink price feed interface
    uint256 public fedPriceUSD; // Current FED price in USD (wei)
    address public owner; // Contract owner address
    ERC20Base public fedToken; // FED token contract interface
    uint8 public fedTokenDecimals;

    event Swap(address fromToken, address toToken, uint256 amountIn, uint256 amountOut);
    event FedPriceUpdated(uint256 newPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can update the FED price");
        _;
    }

    constructor(
        address _priceFeedAddress,
        address _fedTokenAddress
    ) {
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
        fedPriceUSD = 7700000000000; // Set the initial FED price to 0.0077 USD in wei
        owner = msg.sender;
        fedToken = ERC20Base(_fedTokenAddress); // Initialize the FED token interface
        fedTokenDecimals = 18;
    }

    /**
     * @dev Retrieves the current ETH/USD price from the Chainlink price feed.
     */
    function getFedDecimals() public view returns (uint8){
        return fedTokenDecimals;
    } 
  
    function getEthUsdPrice() public view returns (uint256) {
        (, int price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    /**
     * @dev Updates the current FED price in USD (wei). Only the contract owner can call this function.
     * @param newPrice The new FED price in USD (wei).
     */
    function updateFedPrice(uint256 newPrice) external onlyOwner {
        fedPriceUSD = newPrice;
        emit FedPriceUpdated(newPrice);
    }

    /**
     * @dev Swaps ETH for FED tokens with proper decimal handling.
     * @param ethAmount The amount of ETH to swap.
     * @return The amount of FED tokens received.
     */
    function ethToFedSwap(uint256 ethAmount) public payable returns (uint256) {
        uint256 ethPrice = getEthUsdPrice();
        // Calculate the amount of FED tokens to be received using SafeMath to prevent overflow
        uint256 fedAmount = ethAmount.mul(ethPrice).mul(10**uint256(fedTokenDecimals)).div(fedPriceUSD).div(10**18);
        require(fedToken.transfer(msg.sender, fedAmount), "FED transfer failed");
        emit Swap(address(0), address(fedToken), ethAmount, fedAmount); // Emit swap event
        return fedAmount;
    }

    /**
     * @dev Swaps FED tokens for ETH with proper decimal handling.
     * @param fedAmount The amount of FED tokens to swap.
     * @return The amount of ETH received.
     */
    function fedToEthSwap(uint256 fedAmount) public returns (uint256) {
        uint256 ethPrice = getEthUsdPrice();
        // Calculate the amount of ETH to be received using SafeMath to prevent overflow
        uint256 ethAmount = SafeMath.mul(SafeMath.div(SafeMath.mul(fedAmount, fedPriceUSD), ethPrice), SafeMath.div(10**uint256(fedTokenDecimals), 10**18));
        require(fedToken.transferFrom(msg.sender, address(this), fedAmount), "ETH transfer failed");
        payable(msg.sender).transfer(ethAmount);
        emit Swap(address(fedToken), address(0), fedAmount, ethAmount); // Emit swap event
        return ethAmount;
    }

    /**
     * @dev Converts FED tokens to USD.
     * @param fedAmount The amount of FED tokens to convert.
     * @return The equivalent amount in USD.
     */
    function fedToUsd(uint256 fedAmount) public view returns (uint256) {
        return fedAmount / fedPriceUSD;
    }

    /**
     * @dev Converts USD to FED tokens.
     * @param usdAmount The amount in USD to convert.
     * @return The equivalent amount in FED tokens.
     */
    function usdToFed(uint256 usdAmount) public view returns (uint256) {
        return usdAmount * fedPriceUSD;
    }
}
