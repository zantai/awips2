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
package com.raytheon.uf.edex.datadelivery.retrieval.handlers;

import java.util.concurrent.ConcurrentLinkedQueue;

import javax.xml.bind.JAXBException;

import com.raytheon.edex.esb.Headers;
import com.raytheon.uf.common.datadelivery.registry.Coverage;
import com.raytheon.uf.common.serialization.JAXBManager;
import com.raytheon.uf.edex.datadelivery.retrieval.opendap.OpenDapRetrievalResponse;
import com.raytheon.uf.edex.wmo.message.WMOMessage;

/**
 * Deserializes the retrieved data in a retrievalQueue.
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Feb 01, 2013 1543       djohnson     Initial creation
 * Mar 05, 2013 1647       djohnson     Remove WMO header.
 * Mar 19, 2013 1794       djohnson     Read from a queue rather than the file system.
 * 
 * </pre>
 * 
 * @author djohnson
 * @version 1.0
 */
public class DeserializeRetrievedDataFromIngest implements IRetrievalsFinder {

    private final ConcurrentLinkedQueue<String> retrievalQueue;

    private final JAXBManager jaxbManager;

    /**
     * @param retrievalQueue
     */
    public DeserializeRetrievedDataFromIngest(
            ConcurrentLinkedQueue<String> retrievalQueue) {
        this.retrievalQueue = retrievalQueue;
        try {
            this.jaxbManager = new JAXBManager(RetrievalResponseXml.class,
                    OpenDapRetrievalResponse.class, Coverage.class);
        } catch (JAXBException e) {
            throw new ExceptionInInitializerError(e);
        }

    }

    /**
     * {@inheritDoc}
     */
    @Override
    public RetrievalResponseXml findRetrievals() throws Exception {
        String xml = retrievalQueue.poll();

        if (xml == null) {
            return null;
        } else {
            WMOMessage message = new WMOMessage(xml, new Headers());
            return (RetrievalResponseXml) jaxbManager
                    .unmarshalFromXml(new String(message.getMessageBody()));
        }

    }

}