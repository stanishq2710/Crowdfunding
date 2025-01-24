// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


contract CrowdFunding{
    // struct to store project details
    struct Project{
        address creator;
        string name;
        string description;
        uint fundingGoal;
        uint deadline;
        uint amountRaised;
        bool funded;
    }
    //projectId => project details
    mapping(uint => Project) public projects;
    //projectId => user => contribution amount/ funding amount
    mapping(uint => mapping(address => uint)) public contributions;
    //projectId => whether the id is used or not
    mapping(uint => bool) public isIdused;

    uint public totalFundingRaised; //total funding across  all projects
    address public admin;
    mapping(address => bool) public creators; // track allowed creators

    // events are basically logs which you can place for a certain transactions 

    event ProjectCreated (uint indexed projectId, address indexed creator , string name, string description, uint fundingGoal, uint deadline);
    event ProjectFunded (uint indexed projectId, address indexed contributor, uint amount);
    event FundsWithdrawm (uint indexed projectId, address indexed withdrawer, uint amount, string withdrawerType);
    // withdrawertype  ="user" ,  ="admin"
    event CreatorAdded(address creator);
    event CreatorRemoved(address creator);
    event DeadlineExtended(uint indexed projectId, uint newDeadLine);


    constructor() {
        admin = msg.sender;
    }

    // Modifiers for access control
    modifier onlyAdmin() {
        require(msg.sender == admin ,"Only Admin can perform this action");
        _;
    }

    modifier onlyCreator() {
        require(creators[msg.sender], "You are not an allowed creator");
        _;
    }

    // Admin functionalities
    function addCreator(address creator) external onlyAdmin {
        creators[creator] = true;
        emit CreatorAdded(creator);
    }

    function removeCreator(address creator) external onlyAdmin {
        creators[creator] = false;
        emit CreatorRemoved(creator);
    }

    // create project by a creator
    // external public internal private

    function createProject(string memory _name,string memory _description, uint _fundingGoal, uint _durationSeconds, uint _id)external onlyCreator(){
        require(!isIdused[_id], "Project ID is already used");
        isIdused[_id] = true;
        projects[_id] = Project({
            creator: msg.sender,
            name: _name,
            description: _description,
            fundingGoal: _fundingGoal,
            deadline: block.timestamp + _durationSeconds,
            amountRaised: 0,
            funded: false
        });
        emit ProjectCreated(_id, msg.sender, _name, _description, _fundingGoal,block.timestamp + _durationSeconds);
    }
    function fundProject(uint _projectId)external payable{
        Project storage project = projects[_projectId];
        require(block.timestamp <= project.deadline,"Project deadline is already passed");
        require(!project.funded, "Project is already funded");
        require(msg.value >0 ,"Must sent some value of ether");
        project.amountRaised+=msg.value;
        contributions[_projectId][msg.sender] = msg.value;
        emit ProjectFunded(_projectId, msg.sender,msg.value);
        if(project.amountRaised >= project.fundingGoal){
            project.funded = true;
        }
    }

    function userWithdrawFunds(uint _projectId) external payable{
        Project storage project = projects[_projectId];
        require(project.amountRaised <= project.fundingGoal, "Funding Goal is reached, user can't withdraw");
        uint fundContributed = contributions[_projectId][msg.sender];
        payable(msg.sender).transfer(fundContributed);
        emit FundsWithdrawm(_projectId, msg.sender, fundContributed, "user");
    }

    function adminWithdrawFunds(uint _projectId) external payable{
        Project storage project = projects[_projectId];
        uint totalFunding = project.amountRaised;
        require(project.funded, "Funding is not sufficient");
        require(project.creator == msg.sender,"Only project admin can withdraw");
        require(project.deadline <=block.timestamp,"Deadline for project is not reached");
        payable(msg.sender).transfer(totalFunding);
        emit FundsWithdrawm(_projectId, msg.sender, totalFunding, "user");

    }
    // this is example of a read only function
    function isIdusedCall(uint _id)external view returns(bool){
        return isIdused[_id];
    }

    // Extend the deadline of a project
    function extendDeadline(uint _projectId, uint _newDeadLine) external onlyCreator() {
        Project storage project = projects[_projectId];
        require(msg.sender == project.creator);
        require(_newDeadLine > project.deadline);
        project.deadline = _newDeadLine;
        emit DeadlineExtended(_projectId, _newDeadLine);
    }

}
