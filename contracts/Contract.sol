// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";

contract DEX is ERC20Base {
    address public token;

    /**
     * @dev Initializes the DEX contract with the specified token address and ERC20 parameters.
     * @param _token The address of the ERC20 token to be used in the DEX.
     * @param _defaultAdmin The default admin address for the ERC20Base contract.
     * @param _name The name of the ERC20 token.
     * @param _symbol The symbol of the ERC20 token.
     */
    constructor(
        address _token,   
        address _defaultAdmin,
        string memory _name,
        string memory _symbol
    ) ERC20Base(_defaultAdmin, _name, _symbol) {
        token = _token;
    }

    /**
     * @dev Retrieves the balance of the specified token held by the DEX contract.
     * @return The balance of the token in the DEX contract.
     */
    function getTokensInContract() public view returns (uint256) {
        return ERC20Base(token).balanceOf(address(this));
    }

    /**
     * @dev Adds liquidity to the DEX by depositing tokens and ETH.
     * @param _amount The amount of tokens to deposit.
     * @return The amount of liquidity tokens minted.
     */
    function addLiquidity(uint256 _amount) public payable returns (uint256) {
        require(msg.value > 0 && _amount > 0, "Invalid input");

        uint256 _liquidity;
        uint256 balanceInEth = address(this).balance;
        uint256 tokenReserve = getTokensInContract();
        ERC20Base _token = ERC20Base(token);

        if (tokenReserve == 0) {
            require(msg.value == _amount, "ETH amount must equal token amount initially");
            _token.transferFrom(msg.sender, address(this), _amount);
            _liquidity = balanceInEth;
            _mint(msg.sender, _amount);
        } else {
            uint256 reservedEth = balanceInEth - msg.value;
            require(
                _amount >= (msg.value * tokenReserve) / reservedEth,
                "Amount of tokens sent is less than the minimum tokens required"
            );
            _token.transferFrom(msg.sender, address(this), _amount);
            _liquidity = (totalSupply() * msg.value) / reservedEth;
            _mint(msg.sender, _liquidity);
        }
        return _liquidity;
    }

    /**
     * @dev Removes liquidity from the DEX by burning liquidity tokens and transferring tokens/ETH to the user.
     * @param _amount The amount of liquidity tokens to burn.
     * @return The amount of ETH and tokens transferred to the user.
     */
    function removeLiquidity(uint256 _amount) public returns (uint256, uint256) {
        require(_amount > 0, "Amount should be greater than zero");

        uint256 _reservedEth = address(this).balance;
        uint256 _totalSupply = totalSupply();
        uint256 _ethAmount = (_reservedEth * _amount) / _totalSupply;
        uint256 _tokenAmount = (getTokensInContract() * _amount) / _totalSupply;

        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_ethAmount);
        ERC20Base(token).transfer(msg.sender, _tokenAmount);

        return (_ethAmount, _tokenAmount);
    }

    /**
     * @dev Calculates the amount of tokens to receive based on the input amount, input reserve, and output reserve.
     * @param inputAmount The input amount of tokens/ETH.
     * @param inputReserve The input reserve of tokens/ETH.
     * @param outputReserve The output reserve of tokens/ETH.
     * @return The amount of tokens to receive.
     */
    function getAmountOfTokens(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "Invalid Reserves");

        uint256 inputAmountWithFee = inputAmount; // No fee applied for simplicity

        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;

        return numerator / denominator;
    }

    /**
     * @dev Swaps ETH for tokens based on the calculated amount.
     */
    function swapEthToToken() public payable {
        uint256 _reservedTokens = getTokensInContract();
        uint256 _tokensBought = getAmountOfTokens(
            msg.value,
            address(this).balance,
            _reservedTokens
        );

        ERC20Base(token).transfer(msg.sender, _tokensBought);
    }

    /**
     * @dev Swaps tokens for ETH based on the calculated amount.
     * @param _tokensSold The amount of tokens to sell.
     */
    function swapTokenToEth(uint256 _tokensSold) public {
        uint256 _reservedTokens = getTokensInContract();
        uint256 ethBought = getAmountOfTokens(
            _tokensSold,
            _reservedTokens,
            address(this).balance
        );

        ERC20Base(token).transferFrom(msg.sender, address(this), _tokensSold);
        payable(msg.sender).transfer(ethBought);
    }
}
