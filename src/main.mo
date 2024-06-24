import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Timer "mo:base/Timer";
shared ({ caller = creator }) actor class UserCanister() = this {

    let owner : Principal = creator;
    let nanosecondsPerDay = 24 * 60 * 60 * 1_000_000_000;
    var alive : Bool = true;
    var latestPing : Time.Time = Time.now();

    func _kill() : async () {
        let now = Time.now();
        if (now - latestPing > nanosecondsPerDay) {
            alive := false;
        };
    };

    // Timer to reset the alive status every 24 hours
    let daily = Timer.recurringTimer(#nanoseconds(nanosecondsPerDay), _kill);

    // The idea here is to have a function to call every 24 hours to indicate that you are alive
    public shared ({ caller }) func dailyPing() : async () {
        assert (caller == owner);
        alive := true;
        latestPing := Time.now();
    };

    public query func isAlive() : async Bool {
        return alive;
    };

};
