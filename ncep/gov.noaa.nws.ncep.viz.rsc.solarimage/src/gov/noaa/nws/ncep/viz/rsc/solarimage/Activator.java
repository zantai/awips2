package gov.noaa.nws.ncep.viz.rsc.solarimage;

import gov.noaa.nws.ncep.viz.rsc.solarimage.util.SolarImagePreferences;

import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

/**
 * The activator class controls the plug-in life cycle
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer         Description
 * ------------ ---------- -----------      --------------------------
 * 02/21/2013   958        qzhou, sgurung   Initial creation
 * 
 * </pre>
 * 
 * @author qzhou, sgurung
 * @version 1.0
 */
public class Activator extends AbstractUIPlugin {

    // The plug-in ID
    public static final String PLUGIN_ID = "gov.noaa.nws.ncep.viz.rsc.solarimage"; //$NON-NLS-1$

    private IPreferenceStore myprefs = null;
    // The shared instance
    private static Activator plugin;

    /**
     * The constructor
     */
    public Activator() {
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext
     * )
     */
    public void start(BundleContext context) throws Exception {
        super.start(context);
        plugin = this;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext
     * )
     */
    public void stop(BundleContext context) throws Exception {
        plugin = null;
        super.stop(context);
    }

    /**
     * Returns the shared instance
     * 
     * @return the shared instance
     */
    public static Activator getDefault() {
        return plugin;
    }

    @Override
	public IPreferenceStore getPreferenceStore() {
		
		/*
		 * First time, set defaults for the SolarImage preference store
		 */
		if ( myprefs == null ) {
			myprefs =  super.getPreferenceStore();
			myprefs.setDefault( SolarImagePreferences.NUM_FRAMES, SolarImagePreferences.DEFAULT_NUM_FRAMES);			
		}
		
		return myprefs;
	}
}