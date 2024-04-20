// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LiquidityPool {
    using SafeMath for uint256;

    IERC20 public usdtToken; // USDT token contract interface
    IERC20 public fedToken; // FED token contract interface
    uint256 public usdtReserve; // Reserves of USDT tokens in the pool
    uint256 public fedReserve; // Reserves of FED tokens in the pool
    uint256 public feePercentage; // Fee percentage charged on swaps
    address public feeReceiver; // Address to receive fee
    address public owner;

    event TokensDeposited(address indexed depositor, uint256 usdtAmount, uint256 fedAmount);
    event TokensSwapped(address indexed swapper, uint256 usdtAmount, uint256 fedAmount);
    event FeeCollected(address indexed collector, uint256 feeAmount);
    event ReservesRebalanced(uint256 newUsdtReserve, uint256 newFedReserve);

    constructor(
        address _usdtTokenAddress,
        address _fedTokenAddress,
        uint256 _initialFeePercentage,
        address _feeReceiver
        
        
    ) {
        usdtToken = IERC20(_usdtTokenAddress);
        fedToken = IERC20(_fedTokenAddress);
        feePercentage = _initialFeePercentage;
        feeReceiver = _feeReceiver;
        owner = msg.sender;
    }


     function isOwner() public view returns(bool) {
    return msg.sender == owner;
    }

    /**
     * @dev Allows users to deposit USDT and FED tokens into the liquidity pool.
     * @param usdtAmount The amount of USDT tokens to deposit.
     * @param fedAmount The amount of FED tokens to deposit.
     */

   

    function deposit(uint256 usdtAmount, uint256 fedAmount) external {
        require(usdtAmount > 0 && fedAmount > 0, "Invalid amounts");

        // Transfer tokens from the sender to the liquidity pool contract
        usdtToken.transferFrom(msg.sender, address(this), usdtAmount);
        fedToken.transferFrom(msg.sender, address(this), fedAmount);

        // Update the reserves
        usdtReserve = usdtReserve.add(usdtAmount);
        fedReserve = fedReserve.add(fedAmount);

        emit TokensDeposited(msg.sender, usdtAmount, fedAmount);
    }

    /**
     * @dev Allows users to swap USDT for FED tokens from the liquidity pool.
     * @param usdtAmount The amount of USDT tokens to swap.
     * @return The amount of FED tokens received.
     */
    function swapUsdtToFed(uint256 usdtAmount) external returns (uint256) {
        require(usdtAmount > 0 && usdtReserve >= usdtAmount, "Invalid amount or insufficient reserves");

        // Calculate the amount of FED tokens to be received
        uint256 fedAmount = usdtAmount.mul(fedReserve).div(usdtReserve);

        // Apply fee on the swapped amount
        uint256 feeAmount = fedAmount.mul(feePercentage).div(100);
        fedAmount = fedAmount.sub(feeAmount);

        // Transfer tokens from the pool to the sender
        usdtToken.transfer(msg.sender, usdtAmount);
        fedToken.transfer(msg.sender, fedAmount);

        // Transfer fee to fee receiver
        fedToken.transfer(feeReceiver, feeAmount);

        // Update the reserves
        usdtReserve = usdtReserve.sub(usdtAmount);
        fedReserve = fedReserve.sub(fedAmount);

        emit TokensSwapped(msg.sender, usdtAmount, fedAmount);
        emit FeeCollected(feeReceiver, feeAmount);

        return fedAmount;
    }

    /**
     * @dev Allows the owner to rebalance the reserves by adding/removing tokens from the pool.
     * @param usdtAmount The amount of USDT tokens to add/remove.
     * @param fedAmount The amount of FED tokens to add/remove.
     */
    function rebalanceReserves(uint256 usdtAmount, uint256 fedAmount) external {
        require(msg.sender == owner, "Only the owner can rebalance reserves");

        // Adjust reserves based on the provided amounts
        usdtReserve = usdtReserve.add(usdtAmount);
        fedReserve = fedReserve.add(fedAmount);

        emit ReservesRebalanced(usdtReserve, fedReserve);
    }

    // Other functions for managing liquidity pool administration can be added as needed.
}
