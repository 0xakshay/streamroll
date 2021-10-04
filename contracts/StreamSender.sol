// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import {
    ISuperfluid,
    ISuperToken
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import {
    IConstantFlowAgreementV1
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";


/**
 * A simple stream sender contract 
 */
contract StreamSender {

    event NewClaim(address recipient, int96 flowRate);

    // Superfluid framework addresses: https://docs.superfluid.finance/superfluid/networks/networks
    ISuperfluid public immutable host;
    IConstantFlowAgreementV1 public immutable cfa;
    // Pick a super token to be used
    ISuperToken public immutable token;
    // Fixed flow rate for the participant
    int96 internal immutable flowRate;
    // Fixed number of possible participants
    uint256 public immutable maxParticipants;
    uint256 public participants;
    address public owner;

    mapping(address => bool) private _recipients;

    constructor(
        ISuperfluid _host,
        IConstantFlowAgreementV1 _cfa,
        ISuperToken _token,
        int96 _flowRate,
        uint256 _maxParticipants
    )
    {
        require(address(_host) != address(0), "SSender: host is empty");
        require(address(_cfa) != address(0), "SSender: cfa is empty");
        require(
            address(_token) != address(0),
            "SSender: superToken is empty"
        );

        host = _host;
        cfa = _cfa;
        token = _token;
        flowRate = _flowRate;
        maxParticipants = _maxParticipants;
        owner = msg.sender;
    }

    function claim(address payable recipient) external {
        require(!_recipients[recipient], "StreamSender: Already claimed");
        _recipients[recipient] = true;
        participants++;
        require(participants <= maxParticipants, "SSender: max out number of participants");
        // send some gas token
        recipient.send( 1e17 /* 0.1 */);
        // send a flow
        host.callAgreement(
            cfa,
            abi.encodeWithSelector(
                cfa.createFlow.selector,
                token,
                recipient,
                flowRate,
                new bytes(0)
            ),
            "0x"
        );

        emit NewClaim(recipient, flowRate);
    }

    function withdraw() external {
        require(msg.sender == owner, "SSender: not owner");
        payable(msg.sender).send(address(this).balance);
    }
    
    receive() external payable {
    }
}
