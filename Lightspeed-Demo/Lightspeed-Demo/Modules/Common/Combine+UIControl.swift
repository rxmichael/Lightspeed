//
//  Combine+UIControl.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/23/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import UIKit
import Combine

final class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private let control: Control
    
    init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(eventHandler), for: event)
    }
    
    func request(_ demand: Subscribers.Demand) {
        // We do nothing here as we only want to send events when they occur.
    }
    
    func cancel() {
        subscriber = nil
    }
    
    @objc private func eventHandler() {
        _ = subscriber?.receive(control)
    }
}

struct UIControlPublisher<Control: UIControl>: Publisher {
    
    typealias Output = Control
    typealias Failure = Never
    
    let control: Control
    let event: UIControl.Event
    
    init(control: Control, events: UIControl.Event) {
        self.control = control
        self.event = events
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, S.Failure == UIControlPublisher.Failure, S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: event)
        subscriber.receive(subscription: subscription)
    }
}

protocol CombineCompatible {}

extension UIControl: CombineCompatible {}

extension CombineCompatible where Self: UIControl {
    func publisher(for events: UIControl.Event) -> UIControlPublisher<Self> {
        UIControlPublisher(control: self, events: events)
    }
}

extension CombineCompatible where Self: UISwitch {
    func publisher() -> UIControlPublisher<UISwitch> {
        UIControlPublisher(control: self, events: .primaryActionTriggered)
    }
}

extension CombineCompatible where Self: UIButton {
    func publisher() -> UIControlPublisher<UIButton> {
        UIControlPublisher(control: self, events: .primaryActionTriggered)
    }
}

extension CombineCompatible where Self: UISegmentedControl {
    func publisher() -> UIControlPublisher<UISegmentedControl> {
        UIControlPublisher(control: self, events: .primaryActionTriggered)
    }
}

extension CombineCompatible where Self: UITextField {
    func publisher() -> UIControlPublisher<UITextField> {
        UIControlPublisher(control: self, events: .primaryActionTriggered)
    }
}

extension CombineCompatible where Self: UISlider {
    func publisher() -> UIControlPublisher<UISlider> {
        UIControlPublisher(control: self, events: .primaryActionTriggered)
    }
}

extension CombineCompatible where Self: UIStepper {
    func publisher() -> UIControlPublisher<UIStepper> {
        UIControlPublisher(control: self, events: .primaryActionTriggered)
    }
}


