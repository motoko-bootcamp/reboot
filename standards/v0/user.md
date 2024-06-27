# User Standard

A user comprises one or more canisters. A central kernel helps external callers identify these canisters. This document outlines the base standards for a user.

**Version 0** of the user canister supports:

- Basic Proof-Of-Life (self-declared) requiring a ping every 24 hours.
- Basic contact system (friends).
- Basic messaging system.

This version supports only one canister per user.

## Data

### Friend

```
type Friend = {
    name : Text;
    canisterId : Principal;
}
```

### FriendRequest

```
type FriendRequest = {
    id : Nat;
    name : Text;
    sender : Principal;
    message : Text;
}
```

### FriendRequestResult

```
type FriendRequestResult = Result.Result<(), FriendRequestError>
```

### FriendRequestError

```
type FriendRequestError = {
    #AlreadyFriend;
    #AlreadyRequested;
    #NotEnoughCycles;
};
```

### MessageError

```
type MessageError = {
    #NotEnoughCycles;
    #MemoryFull;
    #MessageTooLong;
    #NotAllowed;
};

```

## Methods

### user_version

This methods returns the current version of the user.
`user_version : () Nat query`;

### user_isAlive

This methods returns the aliveness status of the user.
`user_isAlive: () -> Bool query`

### user_receiveFriendRequest

This method enables anyone to send a Friend request to a user. A friend request needs to contains at least 1B cycles to be
accepted.

`user_receiveFriendRequest : (name : Text, message : Text) -> FriendRequestResult;`

### user_sendFriendRequest

This method enable the user to send a friend request to another user, assuming the receiver have implemented the `receiveFriendRequest`
`endpoint. A friend request needs to contains cycles to be accepted.

`user_sendFriendRequest : (receiver : Principal, message : Text) -> FriendRequestResult;`

### user_getFriendRequests

This method enables the user to see the pending friend requests that have been sent to him.

`user_getFriendRequests : () -> [FriendRequest];`

### user_handleFriendRequest

This method enables the user to accept the friend request.

`user_handleFriendRequest : (id : Nat, accept : Bool) -> Result<(), Text>;`

### user_getFriends

This method enables the user to see his current friends

`user_getFriends : () -> [Friend]`;

### user_removeFriend

`user_removeFriend : (canisterId : Principal) -> Result<(), Text>;`

### user_sendMessage

This method enables the user to send a message request to another user assuming the receiver has implemented the `user_receiveMessage` endpoint.
A message needs to contain at least 1B cycles to be treated. Only user that are your friends can accept your messages.

`user_sendMessage : (canisterId : Principal, message : Text) -> Result<(), Text>;`

### user_receiveMessage

This method enables the user to receive a message request coming from another user. A message needs to contain at least 1B cycles to be treated. Only your friends can send you messages.

`user_receiveMessage : (message : Text) -> Result<(), Text>;`

### user_readMessages

This method enables the user to access his messages.
`users_readMessages : () -> [(Nat, Text)];`

### user_clearMessage

This method enables the user to clear the message with the specified id.

`user_clearMessage : (id : Nat) -> Result<(), Text>;`

### user_clearMessages

This method enables the user to clear all his messages.

`user_clearMessages: () -> Result<(),Text>;`
