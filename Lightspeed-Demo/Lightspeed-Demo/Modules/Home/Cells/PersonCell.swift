//
//  PersonCell.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/17/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import UIKit

class PersonCell: UITableViewCell {
    let labelStackView = UIStackView()
    let nameLabel = UILabel()
    let planetLabel = UILabel()
    let logoImageView = UIImageView()
    
    private struct Padding {
        static let inner: CGFloat = 16
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Palette.personCell
        selectionStyle = .none
        
        setupLabel()
        setupImageView()
        setupStackView()
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(labelStackView)
        
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func estimatedHeight() -> CGFloat {
        return 130
    }
    
    func setupLabel() {
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = Palette.personCellText
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        planetLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        planetLabel.textColor = Palette.personCellText
        planetLabel.numberOfLines = 0
        planetLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupImageView() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
    }
    
    func setupStackView() {
        labelStackView.addArrangedSubview(logoImageView)
        labelStackView.addArrangedSubview(planetLabel)
        labelStackView.axis = .horizontal
        labelStackView.spacing = .leastNormalMagnitude
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func createConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
            constant: Padding.inner),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
            constant: Padding.inner),
            
            labelStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,
                                                constant: Padding.inner),
            labelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
            constant: -Padding.inner),
            ])
    }
    
    func setup(withInfo cellInfo: CellInfo) {
        nameLabel.text = cellInfo.person.name
        planetLabel.text = cellInfo.planet.name
        logoImageView.image = UIImage(named: "rocket")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        planetLabel.text = nil
        logoImageView.image = nil
    }
}
