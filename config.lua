Config                            = {}
Config.Locale                     = 'cs'
Config.EnableLicenses = true
Config.jobs = {}

Config.jobs["police"] = {

    citizenActions = {
        idCard = true,
        search = true,
        handcuff = true, 
        drag = true,
        putInVehicle = true,
        outTheVehicle = true, 
        bills = true,
        unpaidBills = true,
        licenses = true
    },

    vehicleActions = {
        vehicleInfo = true,
        pickLock = true,
        impound = true,
    },
}

Config.jobs["unemployed"]  = {

    citizenActions = {
        idCard = true,
        search = true,
        handcuff = true, 
        drag = true,
        putInVehicle = true,
        outTheVehicle = true, 
        bills = true,
        unpaidBills = true,
        licenses = true
    },

    vehicleActions = {
        vehicleInfo = true,
        pickLock = true,
        impound = true,
       
    },
}