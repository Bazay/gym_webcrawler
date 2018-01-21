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
