# Friend standard

The Friend standard is a standard for User Canister on the Internet Computer to be able to send friend requests to each other and store contact information about each other.

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

## Methods

### reboot_friends_receiveFriendRequest

This method enables anyone to send a Friend request to a user. A friend request needs to contains cycles to be accepted.
`reboot_friends_receiveFriendRequest : (name : Text, message : Text) -> FriendRequestResult;`

### reboot_friends_sendFriendRequest

This method enable the user to send a friend request to another user, assuming the receiver have implemented the `receiveFriendRequest `
`endpoint. A friend request needs to contains cycles to be accepted.

`reboot_friends_sendFriendRequest : (receiver : Principal, message : Text) -> FriendRequestResult;`

### reboot_friends_getFriendRequests

This method enables the user to see the pending friend requests that have been sent to him.

`reboot_friends_getFriendRequests : () -> [FriendRequest];`

### reboot_friends_handleFriendRequest

This method enables the user to accept the friend request.

`reboot_friends_handleFriendRequest` : (id : Nat, accept : Bool) -> Result<(), Text>;`

### reboot_friends_getFriends

This method enables the user to see his current friends

`reboot_friends_getFriends` : () -> [Friend];

### reboot_friends_removeFriend

`reboot_friends_removeFriend : (canisterId : Principal) -> Result<(), Text>;`

## reboot_supportedStandards

Returns the list of standards this user supports.
Any user supporting the Friend standard MUST include a record with the name field equal to "Friends" in that list.
`reboot_supportedSupported : () -> (vec record { name : text; url : text }) query;`

## Implementation

### Friend Request Fee (Cycles)

Sending a friend request should be associated with attaching some cycles to the call. The amount of cycles to be sent attached to be superior or equal to 1 Billion.
