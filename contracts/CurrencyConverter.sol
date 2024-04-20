// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Quarsar.sol"; // Import your Quasar oracle interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CurrencyConverter {
    using SafeMath for uint256;

    Quasar internal quasarOracle; // Quasar oracle interface
    IERC20 public usdtToken; // USDT token contract interface
    uint256 public kesUsdtRate; // 1 KES = kesUsdtRate USDT
    address public owner;

    event KesUsdtRateUpdated(uint256 newRate);
    event UsdtConvertedToKes(address indexed converter, uint256 usdtAmount, uint256 kesAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can update the KES/USDT rate");
        _;
    }

    constructor(
        address _quasarOracleAddress,
        address _usdtTokenAddress,
        uint256 _initialKesUsdtRate
    ) {
        quasarOracle = Quasar(_quasarOracleAddress); // Initialize Quasar oracle interface
        usdtToken = IERC20(_usdtTokenAddress);
        kesUsdtRate = _initialKesUsdtRate;
        owner = msg.sender;
    }

    function updateKesUsdtRate(uint256 newRate) external onlyOwner {
        kesUsdtRate = newRate;
        emit KesUsdtRateUpdated(newRate);
    }

    function convertUsdtToKes(uint256 usdtAmount) external returns (uint256) {
        require(usdtAmount > 0, "Invalid amount");

        // Get the current USDT price from the Quasar oracle
        uint256 usdtPrice = quasarOracle.getPrice(1); // Assuming USDT has ID 1 in Quasar oracle

        // Calculate the amount of KES to be received
        uint256 kesAmount = usdtAmount.mul(kesUsdtRate).div(usdtPrice);

        // Transfer USDT tokens from the converter to this contract
        usdtToken.transferFrom(msg.sender, address(this), usdtAmount);

        // Emit event and transfer KES tokens to the converter
        emit UsdtConvertedToKes(msg.sender, usdtAmount, kesAmount);
        return kesAmount;
    }
}
