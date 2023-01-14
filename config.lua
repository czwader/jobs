Config = {}
Config.jobs = {}
Config.Locale = 'cs'
Config.EnableLicenses   = false
Config.EnableESXIdentity = true
Config.EnableESXOptionalneeds = true
Config.inventory = true

Config.jobs["neutral"] = {
    allowJobs = {
        ["unemployed"] = true,
        ["vanila"] = true
    },
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

Config.jobs["legal"]  = {
    allowJobs = {
        ["sheriff"] = true,
        ["police"] = true
        },
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

Config.jobs["nelegal"]  = {
    allowJobs = {
        ["grove"] = true,
        ["ballas"] = true
        },
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