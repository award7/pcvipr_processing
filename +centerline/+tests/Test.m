classdef Model < matlab.unittest.TestCase
    
    % dataDir
    methods(Test)

        function testSetDataDir(testCase)
            % test that the property was set correctly
            obj = CenterlineApp.MainApp.Model();
            obj.setDataDir(pwd);
            testCase.verifyEqual(obj.DataDir, pwd);
        end

        function testSetDataDirNonFolder(testCase)
            % test that "Folder does not exist" error is thrown
            obj = CenterlineToolApp.Model();
            val = "foo";
            err = 'MATLAB:validators:mustBeFolder';
            testCase.verifyError(@() obj.setDataDir(val), err);
        end

        function testSetDataNonText(testCase)
            % test that fcn only accepts txt input
            obj = CenterlineToolApp.Model();
            val = 0;
            err = 'MATLAB:validators:mustBeNonzeroLengthText';
            testCase.verifyError(@() obj.setDataDir(val), err);
        end
    end
    
    % fov    
    methods (Test)

        function testSetFOV(testCase)
            obj = CenterlineToolApp.Model();
            % TODO: use realistic vals
            val = [];
            obj.setFOV(val);
            expected = val/10;
            testCase.verifyEqual(obj.FOV, expected);
        end
        
    end
    
    % mag
    methods (Test)
        
        function testSetMAG(testCase)
            obj = CenterlineToolApp.Model();
            % TODO: use realistic vals
            val = [];
            obj.setMAG(val);
            testCase.verifyEqual(obj.MAG, val);
        end
        
    end
    
    % noFrames
    methods (Test)

        function testSetNoFrames(testCase)
            % test that the property was set correctly
            obj = CenterlineToolApp.Model();
            val = 1;
            obj.setNoFrames(val);
            testCase.verifyEqual(obj.NoFrames, val);
        end
        
        function testSetNoFramesNonNumeric(testCase)
            % test that fcn only accepts numeric input
            obj = CenterlineToolApp.Model();
            val = "foo";
            err = "MATLAB:validators:mustBeNumericOrLogical";
            testCase.verifyError(@() obj.setNoFrames(val), err);
        end
        
        function testSetNoFramesNonScalar(testCase)
            % test that fcn only accepts 1x1 scalar
            obj = CenterlineToolApp.Model();
            val = [1,2];
            err = "MATLAB:validation:IncompatibleSize";
            testCase.verifyError(@() obj.setNoFrames(val), err);
        end
        
        function testSetNoFramesNonInt(testCase)
            % test that fcn only accepts int
            obj = CenterlineToolApp.Model();
            val = 1.1;
            err = "MATLAB:validators:mustBeInteger";
            testCase.verifyError(@() obj.setNoFrames(val), err);
        end
        
        function testSetNoFramesNonPos(testCase)
            % test that fcn only accepts positive, non-zero val
            obj = CenterlineToolApp.Model();
            val = -1;
            err = "MATLAB:validators:mustBePositive";
            testCase.verifyError(@() obj.setNoFrames(val), err);
        end
        
    end
    
    % res
    methods (Test)
        
        function testSetRes(testCase)
            obj = CenterlineToolApp.Model();
            val = [];
            obj.setRes(val);
            testCase.verifyEqual(obj.Res, val);
        end
    end
    
    % timeMIP
    methods(Test)    
        
        function testSetTimeMIP(testCase)
            obj = CenterlineToolApp.Model();
            val = [];
            obj.setTimeMIP(val);
            testCase.verifyEqual(obj.TimeMIP, val);
        end
        
    end
    
    % timeRes
    methods (Test)
        
        function testSetTimeRes(testCase)
            obj = CenterlineToolApp.Model();
            val = [];
            obj.setTimeRes(val);
            testCase.verifyEqual(obj.TimeRes, val);
        end
        
    end
    
    % segment
    methods (Test)
        
        function testSetSegment(testCase)
            obj = CenterlineToolApp.Model();
            val = [];
            obj.setSegment(val);
            testCase.verifyEqual(obj.Segment, val);
        end
        
    end
    
    % vel
    methods (Test)
    
        function testSetVel(testCase)
            obj = CenterlineToolApp.Model();
            val = [];
            obj.setVel(val);
            testCase.verifyEqual(obj.Vel, val);
        end
        
    end
    
    % velMean
    methods (Test)
        
        function testSetVelMean(testCase)
            obj = CenterlineToolApp.Model();
            val = [];
            obj.setVelMean(val);
            testCase.verifyEqual(obj.VelMean, val);
        end
        
    end
    
    % velEncoding
    methods (Test)
        function testSetVelEncoding(testCase)
            obj = CenterlineToolApp.Model();
            val = 1;
            obj.setVelEncoding(val);
            testCase.verifyEqual(obj.VelEncoding, val);
        end
        
        function testSetVelEncodingNonScalar(testCase)
            % test that fcn only accepts 1x1 scalar
            obj = CenterlineToolApp.Model();
            val = [1,2];
            err = "MATLAB:validation:IncompatibleSize";
            testCase.verifyError(@() obj.setVelEncoding(val), err);
        end
        
        function testSetVelEncodingNonNumeric(testCase)
            % test that fcn only accepts numeric input
            obj = CenterlineToolApp.Model();
            val = "foo";
            err = "MATLAB:validators:mustBeNumeric";
            testCase.verifyError(@() obj.setVelEncoding(val), err);
        end
        
    end
    
end

