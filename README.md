# Centerline Tool
**Version: 2.0
**Release Date: 
**Languages: 
    - Matlab
    - SQL (optional)
**Dependencies:
    - Matlab R2020B or newer
    - Image Processing Toolbox
    - 
**Contributors:
    - Aaron Ward


## Quickstart

1. Type `centerline_tool` in Matlab command window
2. Load VIPR data via `Load Data`
3. Perform background phase correction
4. Perform feature extraction via `Feature Extraction`
5. Select vessels via `Select Vessel and Segment`
6. View segmented vessels and corresponding vessel parameter plots
7. Save necessary data via `Save Data`


## Synopsis

> Centerline Tool is a Matlab-based GUI to analyze phase contrast vastly-undersampled projection reconstruction (PC VIPR) MRI data, 
specifically of the brain. Depending on the velocity encoding (VENC) used during the MRI acquisition, various cerebral vessels 
will be available for analysis.

### Prerequisites

> Please see "Dependencies" for necessary software.
> Hardware:
    - Processor:
    - RAM: Minimum 8 GB
    - Video card:     
> Each PC VIPR scan data must already be reconstructed into the desired number of frames and each scan stored in its own 
directory. Centerline Tool does **not** perform the necessary reconstruction.

### centerline_tool.mlapp
> *Matlab app designer application*
> Main GUI for loading data, performing preprocessing, and calling most other GUIs

>> **Properties**
    *public*
        - `vipr_obj`: 
            - main object for containing all of the necessary data related to the analysis. 
            - Created by the `loadVIPR` class.
    *private*
        - `phase_correction_app`: 
            - property to contain the `background_phase_correction_app.mlapp` object.
        - `vessel_3D_app`: 
            - property to contain the `Vessel3D_gui.mlapp` object.
        - `vasculature_patch`: 
            - image patch object for displaying vasculature

>> **Functions**
    *public*
        - `viewAngio(app)`: 
            1. view 3D vasculature after background phase correction
        - `end_vessel_selection(app, vessel_struct)`: 
            1. calculate selected vessel parameters
            2. place in structure
            3. call `Vessel3D_gui.mlapp`
            
>> **Callbacks**
    - `startupFcn(app)`
        - runs at app creation. 
        1. centers window.
    
    - `LoadDataButtonPushed(app, event)`
        - callback for "Load Data" button. 
        1. deletes any instantiated *vipr_obj*
        2. calls `loadVIPR` class to create new instance of *vipr_obj*.
        3. calls `BackgroundPhaseCorrectionButtonPushed` callback.
        
    - `DBConnectionButtonPushed(app, event)`
        *currently not programmed*
        - callback for "DB Connection" button.
        1. establish connection with MS SQL server and database.
        
    - `ReorientButtonPushed(app, event)`
        - callback for "Reorient" button.
        1. reorients 3D vasculature in radiological coronal view
        
    - `BackgroundPhaseCorrectionButtonPushed(app, event)`
        - callback for "Background Phase Correction" button.
        1. calls `background_phase_correction_gui.mlapp` to perform background phase correction
            - object is stored in *app.phase_correction_app* property
        
    - `DrawROIButtonPushed(app, event)`
        *current not programmed*
        - callback for "Draw ROI" button.
        1. draw ROI
        
    - `ViewParametricMapButtonPushed(app, event)`
        *currently not programmed*
        - callback for "View Parametric Map" button.
        
    - `FeatureExtractionButtonPushed(app, event)`
        - callback for "Feature Extraction" button
        1. calls `feature_extraction.m`
            - outputs stored in *app.branchMat* and *app.branchList*
    
    - `SelectVesselandSegmentButtonPushed(app, event)`
        -callback for "Select Vessel and Segment" button
        1. calls `SelectVessel` class to perform vessel selection and subsequent segmentation and visualization
            - object not stored in app property
            
    - `UIFigureCloseRequest(app, event)`
        - callback for window closing
        1. delete any children windows
        2. delete self

    
### background_phase_correction_gui.mlapp
> *Matlab app designer application*
> GUI for performing background phase correction

>> **Properties**
    *private*
        - `image`
            - default = 0.5
        - `vmax` 
            - default = 0.1
        - `cd_thresh`
            - default = 0.15
        - `noise_thresh` 
            - default = 0.15
        - `fit_order`
            - default = 2
        - `apply_correction`
            - default = 1
        - `img1_obj`
        - `img2_obj`
        - `centerline_tool_obj`
        - `phase_correction_obj`


>> **Functions**
    *private*
        - `init_backgroundPhaseCorrection(app)`
        - `updateImages(app)`
        - `saveVariables(app)`
        - `image_value_callback(app)`

>> **Callbacks**
    - `startupFcn`
    - `image_sliderValueChanged(app, event)`
    - `image_spinnerValueChanged(app, event)`
    - `vmax_sliderValueChanged(app, event)`
    - `vmax_spinnerValueChanged(app, event)`
    - `cd_sliderValueChanged(app, event)`
    - `cd_spinnerValueChanged(app, event)`
    - `noise_sliderValueChanged(app, event)`
    - `noise_spinnerValueChanged(app, event)`
    - `reset_fit_buttonButtonPushed(app, event)`
    - `update_buttonButtonPushed(app, event)`
    - `done_buttonButtonPushed(app, event)`
    - `UIFigureCloseRequest(app, event)`


### Vessel3D_gui.mlapp
> *Matlab app designer application*
> GUI for visualization of selected vessels

>> **Properties**
    *public*
        - `centerline_app`
        - `current_vessel`
    
    *private*
        - `parameter_plot_app`
        - `full_vasculature_patch`
        - `vessel_patch`
        - `ITPlane`
        - `plane`
        - `tb`

>> **Functions**
    *public*
        - `add_plane(app)`
        - `update_spinners(app, value)`
    
    *private*
        - `init_axes(app)`
        - `init_window(app)`
        - `plot_full_vasculature(app)`
        - `plot_vessel(app)`
        - `add_voxel_labels(app)`

>> **Callbacks**
    - `startupFcn(app, centerline_app)`
    - `WindowSpinnerValueChanged(app, event)`
    - `LowerVoxelSpinnerValueChanged(app, event)`
    - `IsolateVesselSegmentSwitchValueChanged(app, event)`
    - `ReorientButtonPushed(app, event)`
    - `VesselDropDownValueChanged(app, event)`
    - `vessel3DCloseRequest(app, event)`


### parameter_plot_gui.mlapp
> *Matlab app designer application*
> GUI for visualization of selected vessel parameter plots (e.g. area, flow, etc.) and saving of data

>> **Properties**

>> **Functions**

>> **Callbacks**


### loadVIPR
> *class*
> creates main vipr_obj that will contain all necessary data regarding the current data set being analyzed

>> **Properties**
    *public*
        - `directory`
            - source directory of data
        - `fov`
            - field of view
        - `MAG`
            - MAG data
        - `nframes`
            - number of reconstructed frames
        - `res`
            - spatial (?) resolution
        - `time_res`
            - time resolution
        - `velocity`
            - velocity array
        - `vMean`
            - mean velocity array
        - `venc`
            - velocity encoding

>> **Methods**
    *private*
        - `getDirectory(self)`
            - open folder selection UI to select desired folder
        - `read_header(self)`
            - read vipr header file
            - returns *data_array* cell array
        - `parseArray(self, data_array)`
            - parse *data_array* and set select properties
        - `loadVelocity(self)`
            - load velocity data within .dat files
        - `loadMAG(self)`
            - load MAG data
        - `loadvMean(self)`
            - load mean velocity data
        - `loadDat(self, fname)`
            - read .dat file, reshape array, and cast as single data type
        - `delete(self)`
            - delete object if error is encountered
        

### backgroundPhaseCorrection

### calculateParameters

### dbSave

### MAGrgb

### saveData

### SelectVessel

### feature_extraction

### centerline

### thinning

### FillEulerLUT

### p_EulerInv

### p_is_simple

### p_oct_label

### pk_get_nh

### pk_get_nh_idx

### Skeleton3D

### copyUIAxes

### makeITPlane










