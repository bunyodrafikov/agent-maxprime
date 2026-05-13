# Agent Maxprime

`codex` and `claude` both meter usage in **5-hour rolling windows**. If you
don't start a session, that window's quota is gone, hence wasted. This tool
"primes" each Agebt CLI three times a day (06:30, 11:30, 16:30) so the 5-hour
windows are always opened the moment they reset, maxing out the daily usage
budget on both subscriptions without you thinking about it.

It just spawns each Agent CLI, types "Hey!", waits for the reply, and quits.

---

## Setup

1. **Trust the running folder on Agent CLI.** From inside this repo dir on
   your machine, launch each AI tool, you intend to schedule and accept its 
   "do you trust this folder?" prompt:

   ```sh
   cd path/to/agent-maxprime
   codex      # accept the trust prompt, then Ctrl+C twice
   claude     # same
   ```

   Both default CLIs remember the choice per-directory. Skipping this step means
   every scheduled run will stop at the trust prompt and never reach the
   actual "Hey!" message.

3. (Optional) Edit `launchd/io.github.bunyodrafikov.agent-maxprime.plist` if you want
   different tool set or custom schedule. Otherwise, default values applied:
   
   - **Tools** — `codex` and `claude`.
   - **Scheduled Runs** — 06:30, 11:30, 16:30.

4. Install the schedule:

   ```sh
   ./scripts/install.sh
   ```

That's it. It now fires automatically.

To remove: `./scripts/uninstall.sh`.

---

## Want to test it first?

Run the script by hand:

```sh
./bin/run-checkin.sh                # both codex & claude
./bin/run-checkin.sh codex          # codex only
./bin/run-checkin.sh claude         # claude only
```

Then look at the newest log:

```sh
less -R "$(ls -t ~/Library/Caches/agent-maxprime/run-*.log | head -1)"
```

---

## Troubleshooting

- **`command not found` in the launchd log**:<br>
  Edit `PATH` under `EnvironmentVariables` in the plist to your local `$PATH` value, re-run `./scripts/install.sh`.

- **Check schedule status**:

  ```sh
  launchctl print gui/$UID/io.github.bunyodrafikov.agent-maxprime
  ```
