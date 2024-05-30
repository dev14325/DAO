// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract DAO {
    struct Proposal {
        uint id;
        string description;
        uint amount;
        address payable receipeint;
        uint votes;
        uint end;
        bool isExecuted;
    }

    mapping(address=>bool) private isInvestor;
    mapping(address=>uint) public numOfShares;
    mapping(address=>mapping(uint=>bool)) public isVoted;
    // mapping(address=>mapping(address=>bool)) public withdrawlStatus;
    address[] public investorsList;

    mapping(uint=>Proposal) public proposals;

    uint public totalShares;
    uint public availableFunds;
    uint public contributionTimeEnd;
    uint public nextProposalId;
    uint public voteTime;
    uint public quorem;
    address public manager; 


    constructor(uint _contributionTimeEnd , uint _voteTime , uint _quorem){
        require(_quorem>0 && _quorem<100 ,"Not valid values");
        contributionTimeEnd = block.timestamp + _contributionTimeEnd;
        voteTime = _voteTime;
        quorem = _quorem;
        manager = msg.sender;

    }

    modifier onlyInvestor(){
        require(isInvestor[msg.sender] == true , "you are not an investor");
        _;
    }

    modifier onlyManager(){
        require(manager == msg.sender , "you are not manager");
        _;
    }

    function contribution() public payable {
        require(contributionTimeEnd>=block.timestamp,"contribution time ended");
        require(msg.value > 0 ,"send more than 0 ETH");
        isInvestor[msg.sender] = true;
        numOfShares[msg.sender] = numOfShares[msg.sender] + msg.value;
        totalShares+=msg.value;
        availableFunds+=msg.value;
        investorsList.push(msg.sender);

    }

    function redeemShare (uint amount) public onlyInvestor {
      require(numOfShares[msg.sender]>=amount,"you dont have enough shares");
      require(availableFunds>=amount,"Not enough funds");
      numOfShares[msg.sender] -=amount;
      if(numOfShares[msg.sender]==0){
        isInvestor[msg.sender] = false;


      }
      availableFunds-=amount;
      payable(msg.sender).transfer(amount);

    }

    function transferShare(uint amount , address to) public onlyInvestor {
        // require(isInvestor[msg.sender]==true ,"you are not investor");
        require(availableFunds>=amount ,"Not enough funds");
        require(numOfShares[msg.sender]>=amount,"Not enough shares to send");
        numOfShares[msg.sender]-=amount;
        if(numOfShares[msg.sender]==0){
            isInvestor[msg.sender]==false;
        }
        // payable(to).transfer(amount);
        numOfShares[to]+=amount;
        isInvestor[to] = true;
        investorsList.push(to);
       
    }

 function createProposal(string calldata description , uint amount , address payable receipient) public onlyManager {
    require(availableFunds>=amount,"Not enough funds");
    proposals[nextProposalId] = Proposal(nextProposalId,description,amount,receipient,0
    ,block.timestamp+voteTime,false);

    nextProposalId++;
 }


 function voteProposal(uint proposalId) public onlyInvestor {
    Proposal storage proposal = proposals[proposalId];
    require(isVoted[msg.sender][proposalId]==false ,"you have already voted");
    require(proposal.end >= block.timestamp ," Voting time ended");
    require(proposal.isExecuted==false,"it is already executed");
    isVoted[msg.sender][proposalId] = true;
    proposal.votes+=numOfShares[msg.sender];

 }


 function  executeProposal(uint proposalId) public onlyManager {
    Proposal storage proposal = proposals[proposalId];
    require((proposal.votes*100) /totalShares>=quorem,"Majority does not supoort" );
    proposal.isExecuted = true;
    availableFunds-=proposal.amount;
    _transfer(proposal.amount,proposal.receipeint);

 }

 function _transfer(uint amount , address payable receipeint) public {
    receipeint.transfer(amount);

 }


 function proposalList() public view returns(Proposal[] memory){
    Proposal[] memory arr = new Proposal[](nextProposalId-1);
    for(uint i=0;i<nextProposalId;i++){
        arr[i] = proposals[i];
    }

    return arr;
 }
}