import Http "http";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
actor Board {

    public type HttpRequest = Http.Request;
    public type HttpResponse = Http.Response;
    public type Name = Text;
    public type Mood = Text;
    public type Time = Time.Time;

    stable var logs : [(Name, Mood, Principal, Time)] = [];

    public query func http_request(_request : HttpRequest) : async HttpResponse {
        return ({
            body = Text.encodeUtf8("Reboot!");
            headers = [("Content-Type", "text/plain")];
            status_code = 200;
        });
    };

    // Add a daily check to the board
    // Can only be called once per hour per user
    // The name and mood should be less than 24 characters
    // Logs are stored in the logs array (in chronological order)
    public shared ({ caller }) func writeDailyCheck(
        name : Name,
        mood : Mood,
    ) : async () {

        // Check if the name and mood are less than 24 characters
        if (name.size() > 24 or mood.size() > 24) {
            return;
        };

        // Check if the caller can write (once per hour)
        if (not (_canWrite(caller))) {
            return;
        };

        // Check if the caller is alive
        if (not (await _isAlive(caller))) {
            return;
        };

        let time = Time.now();
        logs := Array.append(logs, [(name, mood, caller, time)]);
        return;
    };

    func _isAlive(p : Principal) : async Bool {
        // Creating the actor reference
        let userCanister = actor (Principal.toText(p)) : actor {
            isAlive : shared () -> async Bool;
        };
        try {
            await userCanister.isAlive();
        } catch (err) {
            return false;
        };
    };

    // Check if the user has written on the board in the last 1 hour
    func _lastWritingTime(p : Principal) : ?Time {
        for (log in logs.vals()) {
            if (log.2 == p) {
                return ?log.3;
            };
        };
        return null;
    };

    func _canWrite(p : Principal) : Bool {
        switch (_lastWritingTime(p)) {
            case null {
                return true;
            };
            case (?lastTime) {
                let currentTime = Time.now();
                if ((currentTime - lastTime) >= 60 * 60 * 1_000_000_000) {
                    return true;
                };
                return false;
            };
        };
    };

    // Get the logs from the board

    public query func getLogs() : async [(Name, Mood, Principal, Time)] {
        return logs;
    };
};
