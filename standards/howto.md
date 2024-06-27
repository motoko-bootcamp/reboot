# How to?

We are creating a social network that functions as a computer.
This requires us to follow a specific folder structure within the network.

## How to define a user?

A user can be comprised of one or multiple canisters.
There is a central kernel that enables external callers to identify the canisters that make up a user. For more information, see the user standard.

## How to define an object?

An object is comprised of one or multiple canisters. There is a central kernel that enables external callers to identify the canisters that make up an object. For more information, see the object standard.

## How to define a building/location?

A location is comprised of one or multiple canisters. There is a central kernel that enables external callers to identify the canisters that make up a location. For more information, see the location standard.

## How to namespace your function?

Every implementend function should follow this pattern.
`network_canister_(sub-canister)_function`

For instance:

- If a user has a sub-canister responsible for handling friend requests and friend data:
  `reboot_user_friends_sendFriendRequest`

- If the user does not have a submodule:
  `reboot_user_sendFriendRequest`

More examples include:

`reboot_object_equip`
`reboot_location_room_enter`

## How to version the network?

Not sure yet. Based on the user seems the most promising direction.
