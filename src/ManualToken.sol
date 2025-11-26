// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract ManualToken {
    mapping(address => uint256) public s_balances;

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function name() public pure returns (string memory) {
        return "Manual Token";
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        uint256 previousBalance = balanceOf(msg.sender) + balanceOf(_to);
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;
        require(
            balanceOf(msg.sender) + balanceOf(_to) == previousBalance,
            "Balance of sender or receiver is not correct"
        );
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
}
