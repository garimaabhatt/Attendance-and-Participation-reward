// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Project {
    address public admin;
    uint256 public rewardRate = 10; // Tokens per attendance/participation
    
    struct Student {
        uint256 tokenBalance;
        uint256 attendanceCount;
        uint256 participationCount;
        bool isRegistered;
    }
    
    mapping(address => Student) public students;
    mapping(address => bool) public instructors;
    
    event StudentRegistered(address indexed student);
    event AttendanceMarked(address indexed student, uint256 tokensEarned);
    event ParticipationRecorded(address indexed student, uint256 tokensEarned);
    event TokensRedeemed(address indexed student, uint256 amount, string purpose);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier onlyInstructor() {
        require(instructors[msg.sender] || msg.sender == admin, "Only instructors can perform this action");
        _;
    }
    
    constructor() {
        admin = msg.sender;
        instructors[msg.sender] = true;
    }
    
    // Core Function 1: Register Student
    function registerStudent(address _student) public onlyInstructor {
        require(!students[_student].isRegistered, "Student already registered");
        students[_student].isRegistered = true;
        emit StudentRegistered(_student);
    }
    
    // Core Function 2: Mark Attendance
    function markAttendance(address _student) public onlyInstructor {
        require(students[_student].isRegistered, "Student not registered");
        students[_student].attendanceCount++;
        students[_student].tokenBalance += rewardRate;
        emit AttendanceMarked(_student, rewardRate);
    }
    
    // Core Function 3: Record Participation
    function recordParticipation(address _student) public onlyInstructor {
        require(students[_student].isRegistered, "Student not registered");
        students[_student].participationCount++;
        students[_student].tokenBalance += rewardRate;
        emit ParticipationRecorded(_student, rewardRate);
    }
    
    // Additional helper functions
    function redeemTokens(uint256 _amount, string memory _purpose) public {
        require(students[msg.sender].isRegistered, "Student not registered");
        require(students[msg.sender].tokenBalance >= _amount, "Insufficient tokens");
        students[msg.sender].tokenBalance -= _amount;
        emit TokensRedeemed(msg.sender, _amount, _purpose);
    }
    
    function getStudentDetails(address _student) public view returns (
        uint256 tokenBalance,
        uint256 attendanceCount,
        uint256 participationCount
    ) {
        Student memory student = students[_student];
        return (student.tokenBalance, student.attendanceCount, student.participationCount);
    }
    
    function addInstructor(address _instructor) public onlyAdmin {
        instructors[_instructor] = true;
    }
    
    function removeInstructor(address _instructor) public onlyAdmin {
        instructors[_instructor] = false;
    }
    
    function updateRewardRate(uint256 _newRate) public onlyAdmin {
        rewardRate = _newRate;
    }
}
