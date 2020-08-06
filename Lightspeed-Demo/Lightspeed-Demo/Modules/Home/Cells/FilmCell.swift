//
//  FilmCell.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/17/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import UIKit

class FilmCell: UITableViewCell {
    let labelStackView = UIStackView()
    let nameLabel = UILabel()
    let directorLabel = UILabel()
    let openingCrawlCountLabel = UILabel()
    
    private struct Padding {
        static let inner: CGFloat = 16
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Palette.filmCell
        selectionStyle = .none
        
        setupLabels()
        setupStackView()
        
        contentView.addSubview(labelStackView)
        
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func estimatedHeight() -> CGFloat {
        return 130
    }
    
    private func setupLabels() {
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = Palette.fillCellText
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        directorLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        directorLabel.textColor = Palette.fillCellText
        directorLabel.numberOfLines = 0
        directorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        openingCrawlCountLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        openingCrawlCountLabel.textColor = Palette.fillCellText
        openingCrawlCountLabel.numberOfLines = 0
        openingCrawlCountLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupStackView() {
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(directorLabel)
        labelStackView.addArrangedSubview(openingCrawlCountLabel)
        labelStackView.axis = .vertical
        labelStackView.spacing = 10
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func createConstraints() {
        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                constant: Padding.inner),
            labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor,
            constant: Padding.inner),
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
            constant: -Padding.inner),
            labelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                              constant: -Padding.inner),
            ])
    }
    
    func setup(withFilm film: Film) {
        nameLabel.text = film.title
        directorLabel.text = "Directed by: \(film.director)"
        openingCrawlCountLabel.text = "Opening Crawl Count: \(film.openingCrawlWordCount)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        directorLabel.text = nil
        openingCrawlCountLabel.text = nil
    }
}
