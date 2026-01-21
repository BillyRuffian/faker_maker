-- DONE - sorta
2. get attributes including embedded attr -- THIS WORKS IF USING THE FACTORY PARAMETER, NOT PROC EMBEDDED FACTORIES -- NEED A CHANGE TO OSL FACTORIES
3. What the hell is going on with @embedded factories -- why is this always nil  CHECK -- FOR THE LOVE OF GOD, WRITE DOCUMENTATION FOR THIS
4. Factory#attribute_names line ~ 110

-- TODO

1. nested builds using the build method -- this is hidden at the moment, it sets the value of the key to a hash rather than recursively calling the field#field method
5. FM[:foo].build( attributes: { does_not_exist: 1 }, raise_on_error: false ) # RAISE_ON_ERROR
5. FM[:foo].build( attributes: { does_not_exist: 1 }, strict: false ) # RAISE_ON_ERROR
5. FM[:foo].build( attributes: { does_not_exist: 1 }, very_strict: false ) # RAISE_ON_ERROR


building embedded factories need to know the build options passed in to the top level build call -- e.g. is chaos on or not

check naming strategies still work