//
//  PersonHeaderCell.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/17/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import UIKit

class PersonHeaderCell: UITableViewHeaderFooterView {
    
    let labelStackView = UIStackView()
    let profileImage = UIImageView()
    let nameLabel = UILabel()
    let genderLabel = UILabel()
    let birthLabel = UILabel()
    let bottomStackView = UIStackView()
    let bottomStackBackgoundView = UIView()
    let filmLabel = UILabel()
    
    private struct Padding {
        static let inner: CGFloat = 16
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = Palette.personHeaderBg
        self.backgroundView = backgroundView
        
        setupLabels()
        setupImageView()
        setupStackView()
        
        contentView.addSubview(labelStackView)
        contentView.addSubview(profileImage)
        contentView.addSubview(bottomStackView)
        
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func estimatedHeight() -> CGFloat {
        return 200
    }
    
    func setupImageView() {
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.image = UIImage(named: "star_wars")
        profileImage.contentMode = .scaleAspectFit
    }
    
    func setupLabels() {
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = Palette.personCell
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        genderLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        genderLabel.textColor = Palette.personCell
        genderLabel.numberOfLines = 0
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        birthLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        birthLabel.textColor = Palette.personCell
        birthLabel.numberOfLines = 0
        birthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        filmLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        filmLabel.textColor = Palette.personCell
        filmLabel.numberOfLines = 0
        filmLabel.text = "Filmograhy".uppercased()
        filmLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupStackView() {
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(genderLabel)
        labelStackView.addArrangedSubview(birthLabel)
        labelStackView.axis = .vertical
        labelStackView.distribution = .fillEqually
        labelStackView.spacing = 5
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomStackView.insertSubview(bottomStackBackgoundView, at: 0)
        bottomStackView.addArrangedSubview(filmLabel)
        bottomStackBackgoundView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackBackgoundView.backgroundColor = Palette.filmsHeaderBg
        bottomStackView.axis = .vertical
        bottomStackView.alignment = .center
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func createConstraints() {
        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor,
                                                constant: Padding.inner),
            labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                constant: Padding.inner),
            profileImage.centerYAnchor.constraint(equalTo: labelStackView.centerYAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 100),
            
            bottomStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomStackView.topAnchor.constraint(equalTo: labelStackView.bottomAnchor),
            bottomStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomStackView.heightAnchor.constraint(equalToConstant: 40),
            bottomStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            bottomStackBackgoundView.leadingAnchor.constraint(equalTo: bottomStackView.leadingAnchor),
            bottomStackBackgoundView.topAnchor.constraint(equalTo: bottomStackView.topAnchor),
            bottomStackBackgoundView.trailingAnchor.constraint(equalTo: bottomStackView.trailingAnchor),
            bottomStackBackgoundView.bottomAnchor.constraint(equalTo: bottomStackView.bottomAnchor),
            ])
    }
    
    func setup(withPerson person: Person) {
        nameLabel.text = person.name
        genderLabel.text = "Gender: \(person.gender.rawValue.capitalized)"
        birthLabel.text = "Birth year: \(person.birthYear)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        genderLabel.text = nil
        birthLabel.text = nil
    }
}

