# Concept

We need a proof-of-life for our network to identity and track the number of alive participants.

## Implementation 1

In this implementation every user-canister is responsible for indicating his aliveness and everyone is responsible for pinging their canister every 24 hours, otherwise you are considered dead within the network.
