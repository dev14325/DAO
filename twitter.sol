// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract TweetContract {
    struct Tweet {
        uint id;
        address author;
        string content;
        uint createdAt;
    }


    struct Message {
        uint id;
        string content;
        address from;
        address to;
        uint createdAt;
    }


  
    mapping(uint=>Tweet) public tweets;
    mapping(address=>uint[]) public tweetsOf;
    mapping(address=>Message[]) public conversations;
    mapping(address=>mapping(address=>bool)) public operators;
    mapping(address=>address[]) public following;

  

  uint nextId;
  uint nextMessageId;
    

    function _tweet(address _from , string memory _content) internal  {
        tweets[nextId] = Tweet(nextId,_from,_content,block.timestamp);
        nextId++;
       
    }
    function _sendMessage(address _from , address _to , string memory _content) internal  {
        conversations[_from].push(Message(nextMessageId,_content,_from,_to,block.timestamp));
        nextMessageId++;
    }

    function tweet(string memory _content) public {
        _tweet(msg.sender, _content);

    }

    function tweet(address _from , string memory _content) public {
        _tweet(_from, _content);
    }

    function sendMessage(address _to , string memory _content) public {
        _sendMessage(msg.sender, _to, _content);
    }

    function sendMessage(address _from , address _to , string memory _content) public {
        _sendMessage(_from, _to, _content);

    }

    function follow(address _followed) public{
        following[msg.sender].push(_followed);
    } 

    function allow(address _operator) public {
        operators[msg.sender][_operator] = true;
    }

     function disallow(address _operator) public {
        operators[msg.sender][_operator] = false;
    }
}