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
package com.raytheon.uf.viz.thinclient;

import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.util.IPropertyChangeListener;
import org.eclipse.jface.util.PropertyChangeEvent;

import com.raytheon.uf.common.localization.msgs.GetServersRequest;
import com.raytheon.uf.common.localization.msgs.GetServersResponse;
import com.raytheon.uf.common.status.IUFStatusHandler;
import com.raytheon.uf.common.status.UFStatus;
import com.raytheon.uf.common.status.UFStatus.Priority;
import com.raytheon.uf.viz.core.VizApp;
import com.raytheon.uf.viz.core.exception.VizException;
import com.raytheon.uf.viz.core.notification.jobs.NotificationManagerJob;
import com.raytheon.uf.viz.core.requests.ThriftClient;
import com.raytheon.uf.viz.thinclient.preferences.ThinClientPreferenceConstants;

/**
 * TODO Add Description
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Nov 29, 2011            bsteffen     Initial creation
 * 
 * </pre>
 * 
 * @author bsteffen
 * @version 1.0
 */

public class ThinClientNotificationManagerJob extends NotificationManagerJob
        implements IPropertyChangeListener {
    private static final transient IUFStatusHandler statusHandler = UFStatus
            .getHandler(ThinClientNotificationManagerJob.class, "ThinClient");

    private static ThinClientNotificationManagerJob instance;

    private Boolean disableJMS;

    public static synchronized ThinClientNotificationManagerJob getInstance() {
        if (instance == null) {
            instance = new ThinClientNotificationManagerJob();
            setCustomInstance(instance);
        }
        return instance;
    }

    public ThinClientNotificationManagerJob() {
        super();
        IPreferenceStore store = Activator.getDefault().getPreferenceStore();
        disableJMS = store
                .getBoolean(ThinClientPreferenceConstants.P_DISABLE_JMS);
        store.addPropertyChangeListener(this);
        if (!disableJMS) {
            connect(true);
        }
    }

    @Override
    protected void connect(boolean notifyError) {
        if (disableJMS == null || disableJMS) {
            return;
        } else {
            super.connect(notifyError);
        }
    }

    @Override
    public void propertyChange(PropertyChangeEvent event) {
        if (ThinClientPreferenceConstants.P_DISABLE_JMS.equals(event
                .getProperty())) {
            disableJMS = Boolean.valueOf(String.valueOf(event.getNewValue()));
            if (disableJMS) {
                disconnect(true);
            } else {
                if (VizApp.getJmsServer() == null) {
                    GetServersRequest req = new GetServersRequest();
                    GetServersResponse resp;
                    try {
                        resp = (GetServersResponse) ThriftClient
                                .sendLocalizationRequest(req);
                        VizApp.setJmsServer(resp.getJmsServer());
                    } catch (VizException e) {
                        statusHandler.handle(Priority.PROBLEM,
                                e.getLocalizedMessage(), e);
                    }
                }
                connect(true);
            }
        }
    }

}
