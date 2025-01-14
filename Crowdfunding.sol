
pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

contract Crowdfunding {
    address public beneficiary; 
    uint256 public goal;
    uint256 public deadline;
    uint256 public raisedAmount;

    mapping(address => uint256) public contributions;

    event FundRaised(address contributor, uint256 amount);
    event Refunded(address contributor, uint256 amount);

    constructor(
        address _beneficiary,
        uint256 _goal,
        uint256 _deadline 
    ) {
        beneficiary = _beneficiary;
        goal = _goal;
        deadline = block.timestamp + _deadline; // Deadline in seconds from now
    }

    function contribute() public payable {
        require(block.timestamp <= deadline, "Deadline has passed");
        require(msg.value > 0, "Contribution amount must be greater than 0");

        contributions[msg.sender] += msg.value;
        raisedAmount += msg.value;
        emit FundRaised(msg.sender, msg.value);

        if (raisedAmount >= goal) {
            // If goal is reached, transfer funds to beneficiary
            payable(beneficiary).transfer(raisedAmount); 
        }
    }

    function getContributionAmount(address contributor) public view returns (uint256) {
        return contributions[contributor];
    }

    function getRaisedAmount() public view returns (uint256) {
        return raisedAmount;
    }

    function refund() public {
        require(block.timestamp > deadline, "Deadline has not passed yet");
        require(raisedAmount < goal, "Goal has been reached");

        uint256 amountToRefund = contributions[msg.sender];
        require(amountToRefund > 0, "No contributions to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amountToRefund);
        emit Refunded(msg.sender, amountToRefund);
    }
}
