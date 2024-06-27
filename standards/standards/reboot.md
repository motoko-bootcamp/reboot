# Reboot User Standard

The Reboot standard is a standard for User canister on the Internet Computer.

## Methods

### Reboot_isAlive

Returns the aliveness status of the user.

`reboot_isAlive: () -> Bool query`

### Reboot_supportedStandards

Returns a list of the supported standards this user implements.

`reboot_supportedStandards: () -> (vec record { name : text; url : text }) query;`

The result of the call should always have at least one entry,
`record { name = "Reboot"; url = "https://github.com/motoko-bootcamp/reboot/standards/reboot.md" }
