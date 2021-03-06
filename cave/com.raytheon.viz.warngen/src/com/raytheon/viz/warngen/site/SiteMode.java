/**
 * This software was developed and / or modified by Raytheon Company,
 * pursuant to Contract DG133W-05-CQ-1067 with the US Government.
 * 
 * U.S. EXPORT CONTROLLED TECHNICAL DATA
 * This software product contains export-restricted data whose
 * export/transfer/disclosure is restricted by U.S. law. Dissemination
 * to non-U.S. persons whether in the United States or abroad requires
 * an export license or other authorization.
 * 
 * Contractor Name:        Raytheon Company
 * Contractor Address:     6825 Pine Street, Suite 340
 *                         Mail Stop B8
 *                         Omaha, NE 68106
 *                         402.291.0100
 * 
 * See the AWIPS II Master Rights File ("Master Rights File.pdf") for
 * further licensing information.
 **/
package com.raytheon.viz.warngen.site;

import com.raytheon.uf.common.site.SiteMap;
import com.raytheon.uf.viz.core.localization.LocalizationManager;

/**
 * Holds the constants that define if the site is WFO or RFC
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Dec 17, 2010            jsanchez     Initial creation
 * 
 * </pre>
 * 
 * @author jsanchez
 * @version 1.0
 */

public enum SiteMode {
    WFO("WFO"), RFC("RFC");

    private String displayString;

    private static SiteMode siteMode;

    private SiteMode(String displayString) {
        this.displayString = displayString;
    }

    @Override
    public String toString() {
        return this.displayString;
    }

    public static SiteMode getMode() {
        if (siteMode == null) {
            SiteMode.initialize();
        }
        return siteMode;
    }

    public static void initialize() {
        String site = LocalizationManager.getInstance().getCurrentSite();
        siteMode = SiteMap.getInstance().isRFCSite(site) ? RFC : WFO;
    }

}
