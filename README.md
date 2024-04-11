# Train Tracked API

A 'better' train tracking API. Created as part of a Level 5 Computer Science project at the University of Portsmouth

## Getting Started

### Requirements

- A publicly accessible Linux server
- A key for the Rail Delivery Group's LDBSVWS API
- The Dart SDK setup and in your PATH

### Building

- Clone the repository
- Run `dart pub get` to install dependencies
- Run `build.sh` to build for your current platform
- A build executable will be placed in the `out/` folder with the name `train_tracked_api`

### Running

- Run the program once to generate a config file
- Edit the `config.yaml` file, adding your LDBSVWS API key, changing the password, and setting the hostname and port as 
 needed
- Run the program again using your preferred init software (e.g. systemd) to ensure it runs on startup and restarts on
 failure
- Check that you can access the API by opening a web browser and navigating to
 `http://<hostname>:<port>/departures?crs=SOU&token=<password>`
