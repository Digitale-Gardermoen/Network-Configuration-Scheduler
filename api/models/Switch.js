const Config = require('Config');

class Switch {

    constructor(hostname, model, portSpeed) {
        this.hostname = hostname;   // String
        this.model = model;         // String
        this.portSpeed = portSpeed; // Integer
        this.config = {};           // Config object
    }

    getHostname() {
        return this.hostname;
    }

    setHostname(hostname) {
        this.hostname = hostname;
    }

    getModel() {
        return this.model;
    }

    setModel(model) {
        this.model = model;
    }

    generateConfig() {
        let config = new Config();
        this.config = config;   // End statement
    }
};

module.exports = Switch;
