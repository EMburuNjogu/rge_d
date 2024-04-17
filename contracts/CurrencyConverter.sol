// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CurrencyConverter {
    AggregatorV3Interface internal priceFeed;

    constructor(address _priceFeedAddress) {
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    function getEthUsdPrice() public view returns (uint256) {
        (, int price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function ethToFed(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getEthUsdPrice();
        uint256 fedPrice = 100; // Assume 1 FED = 100 USD for simplicity
        uint256 fedAmount = (ethAmount * ethPrice) / fedPrice;
        return fedAmount;
    }

  
}
