module.exports = function(grunt) {

    // Project configuration.
    grunt.initConfig({
        deviceName: function () {
            var deviceName = grunt.option('device');

            var name = "";

            if (deviceName) {
                name += ["DEVICE_TARGET='", deviceName, "' "].join("");
            }

            return name;
        },

        report: function(tag) {
            var options = '-p ios_simulator_quiet -d -f html';
            var output = '-o report_full.html';
            var tags = "";

            if (tag) {
                output = ["-o report_", tag, ".html"].join("");
                tag = '--tags @' + tag;
            }

            return ['bundle exec cucumber', options, output, tag].join(" ");
        },

        testUsingProfile: function(profile, extraParams) {

            var defaultParams = "--tags @done --tags ~@manual --tags ~@pending --tags ~@dev --tags ~@blocked  --tags ~@experimental";
            var rerun_output = ["-f rerun -o rerun_", profile, ".txt"].join("");
            var execution_output = ["-f html -o report_", profile, ".html"].join("");

            if (extraParams) defaultParams = [defaultParams, extraParams].join(" ");

            return ['bundle exec cucumber -p', profile, defaultParams, execution_output, rerun_output].join(" ");
        },

        rerunUsingProfile: function(profile) {

            var rerun_file = ["@rerun_", profile, ".txt"].join("");
            var rerun_report_output = ["-f html -o rerun_report_", profile, ".html"].join("");
            var failed_scenarios_output = ["-f rerun -o failing_scenarios_", profile, ".txt"].join("");

            return ['bundle exec cucumber -p', profile, rerun_file, failed_scenarios_output, rerun_report_output].join(" ");
        },

        shell: {
            checkForFailure: {
                command: "WORDS=$(wc -w failing_scenarios_*.txt | grep total | tr -d '[A-Za-z ]'); if [ $WORDS -ne 0 ]; then exit 1; fi"
            },

            installBundler: {
                options: {
                    stderr: true,
                    stdout: true
                },
                command: 'gem list -i bundler || gem install bundler'
            },

            bundleInstall: {
                options: {
                    stderr: true,
                    stdout: false
                },
                command: 'bundle install'
            },

            generateDocs: {
                options: {
                    stderr: true,
                    stdout: true
                },
                command: "bundle exec yard config load_plugins true && bundle exec yardoc 'features/**/*.rb' 'features/**/*.feature'"
            },

            testIos: {
                command: function () {
                    return '<%= deviceName() %> <%= testUsingProfile("ios_simulator", "--tags ~@device_only") %>';
                }
            },

            testIosDev: {
                command: 'bundle exec cucumber -p ios_simulator -f pretty --tags @dev'
            },

            testIosDevice: {
                command: '<%= testUsingProfile("ios_device", "--tags ~@simulator_only") %>'
            },

            testIosJenkins: {
                command: '<%= testUsingProfile("build_machine", "--tags ~@device_only") %>'
            },

            testIosJenkins4s: {
                command: '<%= testUsingProfile("build_machine_4s", "--tags ~@device_only") %>'
            },

            testIosJenkinsIPad: {
                command: '<%= testUsingProfile("build_machine_ipad", "--tags ~@device_only") %>'
            },

            rerunIosJenkins: {
                command: '<%= rerunUsingProfile("build_machine") %>'
            },

            rerunIosJenkins4s: {
                command: '<%= rerunUsingProfile("build_machine_4s") %>'
            },

            rerunIosJenkinsIPad: {
                command: '<%= rerunUsingProfile("build_machine_ipad") %>'
            },

            testIosCloud: {
                command: 'echo "TODO: This command was not implemented yet."'
            },

            reportPending: {
                command: '<%= report("pending") %>'
            },

            reportDone: {
                command: '<%= report("done") %>'
            },

            reportManual: {
                command: '<%= report("manual") %>'
            },

            reportBlocked: {
                command: '<%= report("blocked") %>'
            },

            reportFull: {
                command: '<%= report() %>'
            }
        }
    });

    var previous_force_state = grunt.option("force");

    grunt.registerTask("force",function(set){
        if (set === "on") {
            grunt.option("force",true);
        }
        else if (set === "off") {
            grunt.option("force",false);
        }
        else if (set === "restore") {
            grunt.option("force",previous_force_state);
        }
    });


    grunt.loadNpmTasks('grunt-shell');

    //Global tasks
    grunt.registerTask('build', ['shell:installBundler', 'shell:bundleInstall']);

    //iOS tasks
    grunt.registerTask('test', ['build', 'shell:testIos']);
    grunt.registerTask('test-dev', ['build', 'shell:testIosDev']);
    grunt.registerTask('test-device', ['build', 'shell:testIosDevice']);
    grunt.registerTask('test-cloud', ['build', 'shell:testIosCloud']);
    grunt.registerTask('checkForFailure', ['force:off', 'shell:checkForFailure', 'force:restore']);
    // grunt.registerTask('test-jenkins-rerun', ['shell:rerunIosJenkins', 'shell:rerunIosJenkins4s', 'shell:rerunIosJenkinsIPad']);
    grunt.registerTask('test-jenkins-rerun', ['shell:rerunIosJenkins']);
    // grunt.registerTask('test-jenkins', ['build', 'force:on', 'shell:generateDocs', 'shell:testIosJenkins', 'shell:testIosJenkins4s', 'shell:testIosJenkinsIPad', 'test-jenkins-rerun', 'checkForFailure']);
    grunt.registerTask('test-jenkins', ['build', 'force:on', 'shell:generateDocs', 'shell:testIosJenkins', 'test-jenkins-rerun', 'checkForFailure']);

    //Report
    grunt.registerTask('report-done', ['build', 'shell:reportDone']);
    grunt.registerTask('report-manual', ['build', 'shell:reportManual']);
    grunt.registerTask('report-pending', ['build', 'shell:reportPending']);
    grunt.registerTask('report-blocked', ['build', 'shell:reportBlocked']);
    grunt.registerTask('report-full', ['build', 'shell:reportFull']);
    grunt.registerTask('report', ['report-done', 'report-manual', 'report-pending', 'report-blocked', 'report-full']);

    grunt.registerTask('gen-docs', ['build', 'shell:generateDocs']);

    grunt.registerTask('default', ['build']);
};
