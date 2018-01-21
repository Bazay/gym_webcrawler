# Gym Webcrawler

**IMPORTANT!**

In order for the webcrawler to work, you must set both of the following environment variables:
```
export user_email=XXXX
export user_password=XXXX
```


### Checking the Class Timetable is Up-to-date

To check validity of current class time table, run:  
```
rspec ./spec/lib/gym_webcrawler/webcrawler_spec.rb
```
**Note:** This spec connects to the gym website, so takes longer than other tests.


### Using `tmux` to Run Webcrawler Asynchronously

First you will want to open a new tmux session using:
```
tmux a
```

From within the opened tmux session run the project with the following command:
```
ruby gym_webcrawler/gym_webcrawler.rb
```

This will run in the current process, not allowing you to exit without stopping the project.  
However, you can get around this by detatching from the tmux session, by pressing `Ctrl + b` followed by `d` key.
