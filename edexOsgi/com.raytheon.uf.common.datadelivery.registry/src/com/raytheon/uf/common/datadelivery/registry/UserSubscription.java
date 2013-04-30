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
package com.raytheon.uf.common.datadelivery.registry;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;

import com.raytheon.uf.common.registry.annotations.RegistryObject;
import com.raytheon.uf.common.registry.annotations.SlotAttribute;
import com.raytheon.uf.common.registry.ebxml.RegistryUtil;
import com.raytheon.uf.common.serialization.annotations.DynamicSerialize;
import com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement;

/**
 * Subscription XML
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Jan 07, 2011    191      dhladky     Initial creation.
 * Mar 13, 2012             jpiatt      Modified for additional elements.
 * Jul  2, 2012    702      jpiatt      Added group name.
 * Aug 10, 2012   1002      mpduff      Change dataset size from int to long.
 * Aug 22, 2012   0743      djohnson    Store data type, fix copy constructor.
 * Aug 31, 2012   1128      mpduff      Fixed subscription status indication.
 * Sep 07, 2012   1102      djohnson    Add some JAXB XmlSeeAlso values.
 * Oct  1, 2012   1103      jpiatt      Added invalid subscription status.
 * Oct 10, 2012   0726      djohnson    Add network route.
 * Oct 26, 2012   1286      djohnson    Add toString, equals, hashcode.
 * Nov 19, 2012 1166        djohnson    Clean up JAXB representation of registry objects.
 * Nov 20, 2012 1166        djohnson    Use attributes for Subscription fields.
 * Nov 20, 2012 1286        djohnson    Add unscheduled.
 * Dec 12, 2012 1433        bgonzale    Refactored Subscription copy ctor into two ctors.
 * Jan 03, 2013 1441        djohnson    Default to no group.
 * Jan 25, 2013 1528        djohnson    Subscription priority is now an enum.
 * Feb 20, 2013 1543        djohnson    Route is now a slot.
 * Mar 29, 2013 1841        djohnson    Renamed to UserSubscription.
 * 
 * </pre>
 * 
 * @author dhladky
 * @version 1.0
 * @param <RegistryTypeObject>
 */
@XmlRootElement
@XmlAccessorType(XmlAccessType.NONE)
@RegistryObject({ Subscription.PROVIDER_NAME_SLOT, Subscription.NAME_SLOT,
        Subscription.DATA_SET_SLOT, Subscription.OWNER_SLOT })
@DynamicSerialize
public class UserSubscription extends RecurringSubscription {
    private static final long serialVersionUID = -6422673887457060034L;

    /**
     * Constructor.
     */
    public UserSubscription() {

    }

    /**
     * Initialization constructor.
     * 
     * @param sub
     *            Subscription object
     * @param name
     *            New subscription name
     */
    public UserSubscription(UserSubscription sub, String name) {
        this(sub);
        this.setName(name);
        this.setId(RegistryUtil.getRegistryObjectKey(this));
    }

    /**
     * Copy constructor.
     * 
     * @param sub
     *            Subscription object
     */
    public UserSubscription(UserSubscription sub) {
        super(sub);
        this.setOwner(sub.getOwner());
    }

    @XmlAttribute
    @DynamicSerializeElement
    @SlotAttribute(OWNER_SLOT)
    private String owner;

    /**
     * Get subscription owner name.
     * 
     * @return subscription owner name
     */
    @Override
    public String getOwner() {
        return owner;
    }

    /**
     * Set subscription owner name.
     * 
     * @param owner
     *            the name of the subscription owner
     */
    public void setOwner(String owner) {
        this.owner = owner;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Subscription copy() {
        return new UserSubscription(this);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Subscription copy(String newName) {
        return new UserSubscription(this, newName);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public InitialPendingSubscription initialPending(String currentUser) {
        return new InitialPendingUserSubscription(this, currentUser);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public PendingSubscription pending(String currentUser) {
        return new PendingUserSubscription(this, currentUser);
    }
}