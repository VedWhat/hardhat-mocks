//SPDX-License-Identifier:MIT
pragma solidity ^0.8.8;

import "./PriceConvertor.sol";

error Unauthorised();

contract FundMe {
    using PriceConvertor for uint256;

    uint256 public constant MINIMUM_USD = 50;

    address[] public funders;
    mapping(address => uint256) funderToAmount;

    address public immutable i_owner;

    AggregatorV3Interface public priceFeed;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorised();
        }
        _;
    }

    function fund() public payable {
        require(
            msg.value.getConvertedPrice(priceFeed) >= MINIMUM_USD,
            "Minimum fund value = 0.01 eth"
        );
        if (funderToAmount[msg.sender] == 0) {
            funders.push(msg.sender);
            funderToAmount[msg.sender] = 0;
        }
        funderToAmount[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < funders.length; i++) {
            funderToAmount[funders[i]] = 0;
        }
        funders = new address[](0);

        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Call failed");
    }

    function getFundedAmount(uint256 _funderIndex)
        public
        view
        onlyOwner
        returns (uint256)
    {
        return funderToAmount[funders[_funderIndex]];
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
