// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract CryptoKids{

    address owner ; // owner ---->dad 

    event LogKidFunding( address addr , uint amount, uint contractBalance) ; // işlem gerçekleştiginde önyüze mesaj göndermek için 

    constructor(){
        owner = msg.sender;  //yapılandırıcı 
    } 

    struct Kid{ // kid nesnesi oluşturduk 
        address  payable walletAddress;
        string firstName; 
        string LastName ;
        uint    ReleaseTime; //Unix Timestamp ne zaman çekilebileceğini ayarlamak için 
        uint    amount;
        bool    canWithDraw;
    }

    Kid[] public kids; // kid dizisini oluşturduk 
    
    modifier OnlyOwner(){ // her defasında kont. yazanın kid için işlem yapmamalı diye genel yazıp ekledik 
         require(msg.sender == owner , "only the owner can  add kids ");
         _;
    }

    function addKids(address payable walletAddress,
        string memory firstName,
        string memory LastName ,
        uint    ReleaseTime, 
        uint    amount,
        bool    canWithDraw) public OnlyOwner {
           
            kids.push(Kid(
                walletAddress ,
                firstName,
                LastName,
                ReleaseTime,
                amount,
                canWithDraw
            ));
    }
    
    function BalanceOf() public view  returns(uint){
        return address(this).balance ; // bu adresteki gönderilen tutarı göster 
    }

    function deposite(address walletAddress)  public payable  {
        addToKidBalance(walletAddress); 
    }

    function addToKidBalance( address walletAddress ) private {
        for(uint i= 0 ; i< kids.length ; i++){ // kid sayısı kadar dolaş 
            if(kids[i].walletAddress == walletAddress ){ //işlem yapılan adres ile kid adresi tutuyorsa gönderilen parayı adrese yatır 
                kids[i].amount += msg.value;
                emit LogKidFunding(walletAddress , msg.value , BalanceOf()); // event mesajını burada gösterecek 
            }
        }
        
    }

    function getIndex(address walletAddress) private view  returns(uint){
        for(uint i= 0 ; i< kids.length ; i++){ // kid sayısı kadar dolaş 
            if(kids[i].walletAddress == walletAddress ){ //işlem yapılan adres ile kid adresi tutuyorsa gönderilen parayı adrese yatır 
               return i ; 
            }
        }
        return 999; // hatalı oldugunu göstermek için 999 kötü bir gösterim 
    } 

    function availableToWithDraw(address walletAddress) public  returns(bool){
        uint i = getIndex(walletAddress);
        require(block.timestamp > kids[i].ReleaseTime, "you cannot withdraw yet ");
        if(block.timestamp > kids[i].ReleaseTime){ // belirlenen yaşa gelmişse para çekmesine izin ver 
            kids[i].canWithDraw = true ;  // bool secenegini true yapıyor 
            return true ; 
        }else {
            return false ;
        }
    }
   

    function withDraw(address payable walletAddress) public payable {
        uint i = getIndex(walletAddress);
        require(msg.sender == kids[i].walletAddress ,"you must be the kid to withdraw" ) ; // gönderen adrese eşit degilse hata ver 
        require(kids[i].canWithDraw == true, "you not are able to withdraw at this time ");
        kids[i].walletAddress.transfer(kids[i].amount);
    }


}