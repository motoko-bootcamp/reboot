import Http "http";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Order "mo:base/Order";
import Result "mo:base/Result";
import Prim "mo:⛔";
actor Board {

    stable let version : (Nat, Nat, Nat) = (0, 0, 1);

    public type Name = Text;
    public type Mood = Text;
    public type Time = Time.Time;
    public type Result<Ok, Err> = Result.Result<Ok, Err>;
    public type Log = (Name, Mood, Principal, Time);

    stable var logs : [Log] = [];

    public type WriteError = {
        #NotEnoughCycles;
        #MemoryFull;
        #NameTooLong;
        #MoodTooLong;
        #NotAllowed;
    };

    // Write a log to the board
    // This function is called by the user canister
    // @cost 1_000_000_000 cycles
    // @restriction canister
    // @param name The name of the user (max 32 characters)
    // @param mood The mood of the user (max 64 characters)
    public shared ({ caller }) func reboot_board_write(
        name : Name,
        mood : Mood,
    ) : async Result<(), WriteError> {

        // Check the available cycles in the call
        let availableCycles = Cycles.available();
        let acceptedCycles = Cycles.accept<system>(availableCycles);
        if (acceptedCycles < 1_000_000_000) {
            return #err(#NotEnoughCycles);
        };

        // Check the length of the name
        if (name.size() > 32) {
            return #err(#NameTooLong);
        };

        // Check the length of the mood
        if (mood.size() > 64) {
            return #err(#MoodTooLong);
        };

        // Check that the caller is a canister
        // This is a tempory hack that won't work in the future (see the link below for more info)
        // https://forum.dfinity.org/t/simple-way-to-detect-if-the-caller-is-a-canister-principal-or-any-other-type-of-non-canister-principal/21995/7)

        if (not (Text.endsWith(Principal.toText(caller), #text("cai")))) {
            return #err(#NotAllowed);
        };

        let time = Time.now();
        logs := Array.append(logs, [(name, mood, caller, time)]);
        return #ok();
    };

    func _isAlive(p : Principal) : async Bool {
        // Creating the actor reference
        let user = actor (Principal.toText(p)) : actor {
            reboot_user_isAlive : shared () -> async Bool;
        };
        try {
            await user.reboot_user_isAlive();
        } catch (err) {
            return false;
        };
    };

    func _logToText(log : (Name, Mood, Principal, Time)) : Text {
        return (log.0 # " " # log.1 # " " # Principal.toText(log.2) # " " # Int.toText(log.3));
    };

    func _logsToText(logs : [(Name, Mood, Principal, Time)]) : Text {
        return Array.foldRight<(Name, Mood, Principal, Time), Text>(
            logs,
            "Name Mood Principal Time\n---\n",
            func(log, acc) {
                return (acc # _logToText(log) # "\n");
            },
        );
    };

    // Read the logs from the board
    public query func reboot_board_read() : async [(Name, Mood, Principal, Time)] {
        return logs;
    };

    // Returns the version of the board
    public shared func reboot_board_version() : async (Nat, Nat, Nat) {
        return version;
    };

    public type HttpRequest = Http.Request;
    public type HttpResponse = Http.Response;
    public query func http_request(_request : HttpRequest) : async HttpResponse {
        return ({
            body = Text.encodeUtf8(
                "Open Internet Summer: the summmer where it all started.\n"
                # "---\n"
                # _logsToText(logs)
                # "---\n"
                # "Version: " # Nat.toText(version.0) # "." # Nat.toText(version.1) # "." # Nat.toText(version.2) # "\n"
                # "Cycle Balance: " # Nat.toText(Cycles.balance()) # " cycles " # "(" # Nat.toText(Cycles.balance() / 1_000_000_000_000) # " T" # ")\n"
                # "Heap size (current): " # Nat.toText(Prim.rts_heap_size()) # " bytes " # "(" # Float.toText(Float.fromInt(Prim.rts_heap_size() / (1024 * 1024))) # " Mb" # ")\n"
                # "Heap size (max): " # Nat.toText(Prim.rts_max_live_size()) # " bytes " # "(" # Float.toText(Float.fromInt(Prim.rts_max_live_size() / (1024 * 1024))) # " Mb" # ")\n"
                # "Memory size: " # Nat.toText(Prim.rts_memory_size()) # " bytes " # "(" # Float.toText(Float.fromInt(Prim.rts_memory_size() / (1024 * 1024))) # " Mb" # ")\n"
            );
            headers = [("Content-Type", "text/plain")];
            status_code = 200;
        });
    };
};
