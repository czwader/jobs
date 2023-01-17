Config = {}
Config.jobs = {}
Config.Locale = 'cs'
Config.EnableLicenses   = false
Config.EnableESXIdentity = true
Config.EnableESXOptionalneeds = true
Config.inventory = true

Config.bossMenu = {
    ["police"] = {
        marker = {
            pos = vector3(565.52,-368.56,43.44),
            type = 1,
            scale = vector3(1.5, 1.5, 0.5),
            color = {
                r = 160,
                g = 32,
                b = 240,
                a = 150,
            },
            rotation = true,
            renderDist = 15,
            inRadius = 1,
            text = "Stiskni  ~INPUT_CONTEXT~ <font face='Fire Sans'>pro otevření bossmenu.</font>",
        },
        allowedActions = {
            canWash = true,
            deposit = true,
            grades = true,
            withdraw = true,
            employees = true
        }
    },
    ["sheriff"] = {
        marker = {
            pos = vector3(661.56,-1028.24,36.2),
            type = 1,
            scale = vector3(1.5, 1.5, 0.5),
            color = {
                r = 160,
                g = 32,
                b = 240,
                a = 150,
            },
            rotation = true,
            renderDist = 15,
            inRadius = 1,
            text = "Stiskni  ~INPUT_CONTEXT~ <font face='Fire Sans'>pro otevření bossmenu.</font>",
        },
        allowedActions = {
            canWash = true,
            deposit = true,
            grades = true,
            withdraw = true,
            employees = true
        }
    }
}

Config.jobs ={
    ["neutral"] = {
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
    },
    ["legal"] = {
        allowJobs = {
            ["police"] = true,
            ["sheriff"] = true
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
    },
}


